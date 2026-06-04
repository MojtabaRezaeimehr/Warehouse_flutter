import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/order/order.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_cubit.dart';
import 'package:warehouse_amf/screens/scan/cubit/scan_type_cubit.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import 'package:warehouse_amf/utils/enums/scan_responses.dart';
import 'package:warehouse_amf/utils/enums/scanner_types.dart';

import '../../../mock/mocked_objects.dart';
import '../../../mock/mocked_services.dart';

void main() {
  late NewOrderCubit cubit;
  late OrderCubit orderCubit;
  late UserAuthCubit userAuthCubit;
  late MockOrdersRepo mockOrdersRepo;
  late ScanCubit scanCubit;
  MockProductsRepo mockProductsRepo = MockProductsRepo();
  AppConfigRepo mockConfigRepo = MockAppConfigRepo();
  UserRepo mockUserRepo = MockUserRepo();
  var mockScanRepo = MockScanRepo();
  var scanTypeCubit = ScanTypeCubit();
  var mockScanHistroyRepo = MockScanHistoryRepo();

  void mockStartOrder(
    bool Function(StartOrderRequest startReq) isValidRequest,
    int returnOrderId,
    OrdersRepo ordersRepo,
  ) {
    when(() => ordersRepo.startOrder(any())).thenAnswer((invocation) async {
      final request = invocation.positionalArguments[0] as StartOrderRequest;
      if (isValidRequest.call(request)) {
        return ApiResponseSucceeded(values: returnOrderId);
      }
      throw Exception("Unexpected request object");
    });
  }

  Future<void> mockPostingBarcode() async {
    await scanCubit.postBarcode(mockScanRequest, ScannerType.manual);
    //in actual code we do not await for putScannedProduct in scanCubit.postBarcode
    //with a future dealyed wit for order count to be updated
    await Future.delayed(const Duration(milliseconds: 200));
  }

  group('NewOrderCubit : finish order - ', () {
    setUpAll(() async {
      registerFallbackValue(mockStartOrderRequest);
      registerFallbackValue(AppConfigKey.brightness);
      registerFallbackValue(mockScanRequest);

      userAuthCubit =
          UserAuthCubit(configRepo: mockConfigRepo, userRepo: mockUserRepo);

      when(() => mockUserRepo.validateUser(any(), any())).thenAnswer(
        (invocation) async {
          return ApiResponseSucceeded(
            values: ValidateUserResponse(user: mockUser, token: "token"),
          );
        },
      );
      when(
        () => mockConfigRepo.updateConfig(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockProductsRepo.fetchproductName(any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: "fake name");
      });
      when(() => mockScanRepo.postBarcode(any())).thenAnswer((_) async {
        return ApiResponseSucceeded(values: ScanResponses.ok);
      });

      //set up an authenticate user for posting barcode
      await userAuthCubit.validateUser("username", "pass");
    });

    setUp(() {
      mockOrdersRepo = MockOrdersRepo();
      orderCubit = OrderCubit(ordersRepo: mockOrdersRepo);
      cubit = NewOrderCubit(
        UserAuthCubit(
          configRepo: mockConfigRepo,
          userRepo: mockUserRepo,
        ),
        TargetPlatform.android,
        ordersRepo: mockOrdersRepo,
        productsRepo: mockProductsRepo,
      )
        ..deviceId = "deviceId"
        ..userId = "userId";
      scanCubit = ScanCubit(
        newOrderCubit: cubit,
        scanTypeCubit: scanTypeCubit,
        userAuthCubit: userAuthCubit,
        scanRepo: mockScanRepo,
        logRepo: FakeLogRepo(),
        scannedHistoryRepo: mockScanHistroyRepo,
      );

      when(() => mockOrdersRepo.postOrderLimitInfo(any(), any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: null);
      });
      when(() => mockOrdersRepo.fetchProductCountInOrder(any(), any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: 24);
      });
      when(() => mockOrdersRepo.deleteOrder(any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: null);
      });
      when(() => mockOrdersRepo.fetchOrdersForUser(any(), any(), any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: ([], false));
      });

      orderCubit.fetchOrdersForUser(userAuthCubit);
    });

    tearDown(() {
      reset(mockOrdersRepo);
      cubit.reset();
      cubit.close();
    });

    test('initial state is NewOrderInitial', () {
      expect(cubit.state, isA<NewOrderInitial>());
    });

    test('do not save order when order has not been started', () async {
      // Arrange
      var orderCubit = OrderCubit(ordersRepo: mockOrdersRepo);
      // Act
      cubit.finishOrder(orderCubit);
      //Assert
      verifyNever(() => mockOrdersRepo.startOrder(any()));
    });

    test('do not save order if scan count is 0', () async {
      // Arrange
      var orderCubit = OrderCubit(ordersRepo: mockOrdersRepo);
      late StartOrderRequest strq;
      mockStartOrder((orderReq) {
        strq = orderReq.copyWith(isNewOrder: false);
        return true;
      }, 2, mockOrdersRepo);
      await cubit.startIncomingOrder();

      // Act
      await cubit.finishOrder(orderCubit);

      // Assert
      verifyNever(() => mockOrdersRepo.startOrder(strq));
    });

    test('notify server of order changes automatically when scan count is > 0',
        () async {
      // Arrange
      late StartOrderRequest strq;
      mockStartOrder((orderReq) {
        strq = orderReq.copyWith(isNewOrder: false);
        return true;
      }, 2, mockOrdersRepo);

      //set up an order to post a barcode and ACT
      await cubit.startIncomingOrder();
      await mockPostingBarcode();

      // Act  - notfify server
      await cubit.finishOrder(orderCubit);

      // Assert
      verify(() => mockOrdersRepo.startOrder(strq)).called(1);
      expect((orderCubit.state as FetchedOrders).orders.length, 0);
    });

    test('delete order when scan count = 0 and finished manually', () async {
      // Arrange
      late StartOrderRequest strq;
      mockStartOrder((orderReq) {
        strq = orderReq.copyWith(isNewOrder: false);
        return true;
      }, 5, mockOrdersRepo);

      //set up an order to post a barcode and ACT
      await cubit.startIncomingOrder();

      // Act  -
      await cubit.finishOrder(orderCubit, manuallyRequested: true);

      // Assert
      expect(cubit.getOrderScannedCount(), 0);
      verify(() => mockOrdersRepo.deleteOrder(5)).called(1);
      verifyNever(() => mockOrdersRepo.startOrder(strq));
    });

    test(
        'cache order and save it on server when scan count > 0 and finished manually',
        () async {
      // Arrange
      late StartOrderRequest strq;
      mockStartOrder((orderReq) {
        strq = orderReq.copyWith(isNewOrder: false);
        return true;
      }, 10, mockOrdersRepo);

      //set up an order to post a barcode and ACT
      await cubit.startReturningOrder(mockCompany);
      await mockPostingBarcode();

      // Act  - notfify server
      await cubit.finishOrder(orderCubit, manuallyRequested: true);

      // Assert
      expect((orderCubit.state as FetchedOrders).orders.length, 1);
      verify(() => mockOrdersRepo.startOrder(strq)).called(1);
    });

    test(
        'update cached api order and notify server when scan count > 0 and finished manually and order is continued api',
        () async {
      // Arrange
      late StartOrderRequest strq;
      mockStartOrder((orderReq) {
        strq = orderReq.copyWith(isNewOrder: false);
        return true;
      }, 1, mockOrdersRepo);
      when(() => mockOrdersRepo.fetchApiOrderProducts(any())).thenAnswer(
        (invocation) async {
          return ApiResponseSucceeded(
            values: {
              "06933395656351": 20,
            },
          );
        },
      );
      when(() => mockOrdersRepo.fetchOrdersForUser(any(), any(), any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: (
          [
            Order(
              distributer: mockCompany,
              date: DateTime.now(),
              id: 1,
              orderType: OrderTypes.outgoing,
              scannedCount: 10,
              documentNo: "12345",
            ),
          ],
          false
        ));
      });

      orderCubit.fetchOrdersForUser(userAuthCubit);

      //set up an order to post a barcode and ACT
      await cubit.startOutgoingOrder(
        mockCompany,
        [
          ScannedProduct(
              product: Product(id: " -1", name: "name", gtin: "06933395656351"),
              scanQuantity: 0,
              maxScanQuantity: 10000)
        ],
        documentCode: "12345",
        orderId: "1",
      );
      await mockPostingBarcode();

      // Act  - notfify server
      await cubit.finishOrder(orderCubit, manuallyRequested: true);

      // Assert
      expect((orderCubit.state as FetchedOrders).orders.length, 1);
      verify(() => mockOrdersRepo.startOrder(strq)).called(2);
    });
  });
}
