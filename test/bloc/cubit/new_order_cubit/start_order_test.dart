import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:warehouse_amf/bloc/cubit/new_order_cubit.dart';
import 'package:warehouse_amf/bloc/cubit/user_auth_cubit.dart';
import 'package:warehouse_amf/models/local/scanned_product.dart';
import 'package:warehouse_amf/models/remote/api_response.dart';
import 'package:warehouse_amf/models/remote/company.dart';
import 'package:warehouse_amf/models/remote/order/load_order_request.dart';
import 'package:warehouse_amf/models/remote/product.dart';
import 'package:warehouse_amf/models/remote/user.dart';
import 'package:warehouse_amf/models/remote/validate_user_response.dart';
import 'package:warehouse_amf/services/local/app_config/app_config_repo.dart';
import 'package:warehouse_amf/services/remote/orders/orders_repo.dart';
import 'package:warehouse_amf/services/remote/user/user_repo.dart';
import 'package:warehouse_amf/utils/enums/app_config_key.dart';
import 'package:warehouse_amf/utils/enums/order_types.dart';
import '../../../mock/mocked_objects.dart';
import '../../../mock/mocked_services.dart';

void main() {
  late NewOrderCubit cubit;
  late MockOrdersRepo mockOrdersRepo;
  late MockProductsRepo mockProductsRepo;
  late AppConfigRepo configRepo;
  late UserRepo userRepo;

  List<ScannedProduct> apiLimitedProducts = [];

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

  group('NewOrderCubit : start order - ', () {
    setUpAll(() async {
      registerFallbackValue(mockStartOrderRequest);
      registerFallbackValue(AppConfigKey.brightness);
      registerFallbackValue(mockScanRequest);

      mockProductsRepo = MockProductsRepo();
      configRepo = MockAppConfigRepo();
      userRepo = MockUserRepo();

      when(() => userRepo.validateUser(any(), any())).thenAnswer(
        (invocation) async {
          return ApiResponseSucceeded(
            values: ValidateUserResponse(
                user: User(
                    id: 584,
                    fname: "fname",
                    lname: "lname",
                    username: "p",
                    phone: "phone",
                    companyNid: "654148984",
                    companyName: "companyName"),
                token: "token"),
          );
        },
      );
    });

    setUp(() {
      apiLimitedProducts = [
        ScannedProduct(
          product: Product(gtin: "75758875785", name: "aergreg", id: "4"),
          scanQuantity: 0,
          maxScanQuantity: 105570,
        ),
        ScannedProduct(
          product: Product(gtin: "785745858", name: "garegaerg", id: "6"),
          scanQuantity: 0,
          maxScanQuantity: 1754750,
        ),
        ScannedProduct(
          product: Product(gtin: "45278688", name: "rhtargf", id: "8"),
          scanQuantity: 0,
          maxScanQuantity: 560,
        ),
      ];

      mockOrdersRepo = MockOrdersRepo();
      when(() => mockOrdersRepo.postOrderLimitInfo(any(), any()))
          .thenAnswer((invocation) async {
        return ApiResponseSucceeded(values: null);
      });

      when(() => mockOrdersRepo.fetchApiOrderProducts(any())).thenAnswer(
        (invocation) async {
          return ApiResponseSucceeded(
            values: {
              apiLimitedProducts[0].product.gtin: 5,
              apiLimitedProducts[1].product.gtin: 452,
              apiLimitedProducts[2].product.gtin: 57,
            },
          );
        },
      );

      cubit = NewOrderCubit(
        UserAuthCubit(
          configRepo: configRepo,
          userRepo: userRepo,
        ),
        TargetPlatform.android,
        ordersRepo: mockOrdersRepo,
        productsRepo: mockProductsRepo,
      )
        ..deviceId = "deviceId"
        ..userId = "userId";
    });

    tearDown(() {
      reset(mockOrdersRepo);
      cubit.reset();
      cubit.close();
    });

    test('initial state is NewOrderInitial', () {
      expect(cubit.state, isA<NewOrderInitial>());
    });

    test('start new INCOMING order test', () async {
      // Arrange
      mockStartOrder((req) {
        return req.isOrderApi == false &&
            req.isNewOrder == true &&
            req.orderid == "" &&
            req.distributerNid == "" &&
            req.orderType == OrderTypes.incoming;
      }, 3, mockOrdersRepo);

      // Act
      await cubit.startIncomingOrder();

      // Assert
      expect(cubit.state, isA<OrderStartedState>());
      expect(cubit.getOrderScannedCount(), 0);
      expect(cubit.isOrderLimited(), false);

      final castedState = cubit.state as OrderStartedState;
      expect(castedState.orderId, 3);
      expect(castedState.distributer, null);
      expect(castedState.orderTypes, OrderTypes.incoming);
    });

    test("start new unlimited OUTGOING order test", () async {
      // Arrange
      mockStartOrder((req) {
        return req.isOrderApi == false &&
            req.isNewOrder == true &&
            req.orderid == "" &&
            req.distributerNid == "6512122" &&
            req.orderType == OrderTypes.outgoing;
      }, 5, mockOrdersRepo);

      // Act
      await cubit.startOutgoingOrder(
        Company(id: "54", name: "fake company", nid: "6512122"),
        [],
      );

      // Assert
      expect(cubit.state, isA<OrderStartedState>());
      expect(cubit.getOrderScannedCount(), 0);
      expect(cubit.isOrderLimited(), false);

      final castedState = cubit.state as OrderStartedState;
      expect(castedState.orderId, 5);
      expect(castedState.distributer, isA<Company>());
      expect(castedState.distributer!.nid, "6512122");
      expect(castedState.orderTypes, OrderTypes.outgoing);
    });

    test("start new limited OUTGOING order test", () async {
      // Arrange
      mockStartOrder((req) {
        return req.isOrderApi == false &&
            req.isNewOrder == true &&
            req.orderid == "" &&
            req.distributerNid == "6512122" &&
            req.orderType == OrderTypes.outgoing;
      }, 5, mockOrdersRepo);

      // Act
      await cubit.startOutgoingOrder(
        Company(id: "54", name: "fake company", nid: "6512122"),
        [
          ScannedProduct(
            product: Product(gtin: "gtin", name: "name", id: "4"),
            scanQuantity: 0,
            maxScanQuantity: 100,
          )
        ],
      );

      // Assert
      expect(cubit.state, isA<OrderStartedState>());
      expect(cubit.getOrderScannedCount(), 0);
      expect(cubit.isOrderLimited(), true);

      final castedState = cubit.state as OrderStartedState;
      expect(castedState.orderId, 5);
      expect(castedState.distributer, isA<Company>());
      expect(castedState.distributer!.nid, "6512122");
      expect(castedState.orderTypes, OrderTypes.outgoing);
      expect(castedState.scannedProducts.first.maxScanQuantity, 100);

      verify(
        () => mockOrdersRepo.postOrderLimitInfo(any(), "5"),
      ).called(1);

      verifyNever(
        () => mockOrdersRepo.fetchApiOrderProducts(any()),
      );
    });

    test("start a new Api OUTGOING order", () async {
      mockStartOrder((req) {
        return req.isOrderApi == true &&
            req.documentNo == "12345" &&
            req.orderType == OrderTypes.outgoing;
      }, 45, mockOrdersRepo);

      await cubit.startOutgoingOrder(
        Company(id: "54", name: "fake company", nid: "999999"),
        apiLimitedProducts,
        documentCode: "12345",
      );

      // Assert
      expect(cubit.state, isA<OrderStartedState>());
      expect(cubit.getOrderScannedCount(), 0);
      expect(cubit.isOrderLimited(), true);

      final castedState = cubit.state as OrderStartedState;
      expect(castedState.orderId, 45);
      expect(castedState.distributer, isA<Company>());
      expect(castedState.distributer!.nid, "999999");
      expect(castedState.orderTypes, OrderTypes.outgoing);
      expect(castedState.documentNo, "12345");

      expect(castedState.scannedProducts.length, 3);
      expect(castedState.scannedProducts[0].maxScanQuantity, 105570);
      expect(castedState.scannedProducts[1].maxScanQuantity, 1754750);
      expect(castedState.scannedProducts[2].maxScanQuantity, 560);

      verify(
        () => mockOrdersRepo.postOrderLimitInfo(any(), "45"),
      ).called(1);

      verifyNever(
        () => mockOrdersRepo.fetchApiOrderProducts(45),
      );
    });

    test("CONTINUE an Api OUTGOING order", () async {
      mockStartOrder((req) {
        return req.isOrderApi == true &&
            req.documentNo == "12345" &&
            req.isNewOrder == false &&
            req.orderid == "45" &&
            req.distributerNid == "999999" &&
            req.orderType == OrderTypes.outgoing;
      }, 45, mockOrdersRepo);

      // Act
      await cubit.startOutgoingOrder(
        Company(id: "54", name: "fake company", nid: "999999"),
        apiLimitedProducts,
        documentCode: "12345",
        orderId: "45",
      );

      // Assert
      expect(cubit.state, isA<OrderStartedState>());
      expect(cubit.getOrderScannedCount(), 514);
      expect(cubit.isOrderLimited(), true);

      final castedState = cubit.state as OrderStartedState;
      expect(castedState.orderId, 45);
      expect(castedState.distributer, isA<Company>());
      expect(castedState.distributer!.nid, "999999");
      expect(castedState.orderTypes, OrderTypes.outgoing);
      expect(castedState.documentNo, "12345");
      expect(castedState.scannedProducts.length, 3);
      expect(
          castedState.scannedProducts
              .where((element) => element.maxScanQuantity != null)
              .length,
          3);
      expect(castedState.scannedProducts[1].maxScanQuantity, 1754750);

      // apiLimitedProducts must be updated with new quantity too
      // which cause posting order limit info to server with valid scanQuantity
      expect(apiLimitedProducts[1].scanQuantity, 452);

      verify(
        () => mockOrdersRepo.postOrderLimitInfo(any(), "45"),
      ).called(1);

      verify(
        () => mockOrdersRepo.fetchApiOrderProducts(45),
      ).called(1);
    });

    test(
        "should not CONTINUE an Api OUTGOING order with failure in updateScannedProducts",
        () async {
      // Arrange
      when(() => mockOrdersRepo.fetchApiOrderProducts(any())).thenAnswer(
        (invocation) async {
          return ApiResponseSucceeded(
            values: {},
          );
        },
      );
      mockStartOrder((req) {
        return req.isOrderApi == true &&
            req.documentNo == "12345" &&
            req.isNewOrder == false &&
            req.orderid == "45" &&
            req.distributerNid == "999999" &&
            req.orderType == OrderTypes.outgoing;
      }, 45, mockOrdersRepo);

      // Act
      await cubit.startOutgoingOrder(
        Company(id: "54", name: "fake company", nid: "999999"),
        apiLimitedProducts,
        documentCode: "12345",
        orderId: "45",
      );

      // Assert
      expect(cubit.state, isA<StartingOrderErrorState>());
      expect(cubit.getOrderScannedCount(), 0);
      expect(cubit.isOrderLimited(), false);

      final castedState = cubit.state as StartingOrderErrorState;
      expect(castedState.message, "failed to load prev order data");
      expect(apiLimitedProducts[1].scanQuantity, 0);

      verify(
        () => mockOrdersRepo.fetchApiOrderProducts(45),
      ).called(1);

      verifyNever(
        () => mockOrdersRepo.postOrderLimitInfo(any(), "45"),
      );
    });
  });
}
