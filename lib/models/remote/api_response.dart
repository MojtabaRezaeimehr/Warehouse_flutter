import 'package:easy_localization/easy_localization.dart';
import 'package:warehouse_amf/utils/enums/translation_keys.dart';
import 'package:warehouse_amf/utils/functions.dart';

abstract class ApiResponse<T> {
  final T? values;

  ApiResponse({this.values});
}

class ApiResponseSucceeded<T> extends ApiResponse<T> {
  ApiResponseSucceeded({required super.values});
}

class ApiResponseFailed<T> extends ApiResponse<T> {
  String message;
  final int? statusCode;
  ApiResponseFailed({required this.message, this.statusCode}) {
    if (statusCode != null) {
      dprint("code is not null-$statusCode");
      if (httpCodes[statusCode] != null) {
        dprint("httpCodes[statusCode]${httpCodes[statusCode]}");
        message = "${httpCodes[statusCode]}\n$message";
      }
    }
    if (message.contains("DioException [connection error]")) {
      message = Translations.connectionFailed.name.tr();
    }
    if (message.length > 120) {
      message = message.substring(0, 119);
    }
  }
}

final Map<int, String> httpCodes = {
  100: "ادامه فرآیند درخواست.",
  101: "تغییر پروتکل.",
  300: "تغییر مسیر چندگانه.",
  301: "تغییر مسیر دائمی.",
  302: "تغییر مسیر موقت.",
  303: "دیدن دیگر مکان.",
  304: "محتوا تغییر نکرده است.",
  307: "تغییر مسیر موقت با حفظ متد.",
  308: "تغییر مسیر دائمی با حفظ متد.",
  400: "درخواست نامعتبر است.",
  401: "عدم اجازه دسترسی.",
  403: "دسترسی غیرمجاز.",
  404: "صفحه یا منبع مورد نظر یافت نشد.",
  405: "متد درخواستی مجاز نیست.",
  406: "محتوای قابل پذیرش یافت نشد.",
  407: "احراز هویت پروکسی لازم است.",
  408: "مهلت درخواست به پایان رسید.",
  409: "تعارض در داده‌ها یا وضعیت.",
  410: "منبع حذف شده است.",
  411: "طول درخواست لازم است.",
  412: "پیش‌شرط درخواست با شکست مواجه شد.",
  413: "اندازه درخواست بیش از حد مجاز است.",
  414: "آدرس درخواست بسیار طولانی است.",
  415: "نوع رسانه پشتیبانی نمی‌شود.",
  416: "محدوده درخواست قابل تأمین نیست.",
  417: "انتظار پاسخ ناموفق بود.",
  422: "موجودیت قابل پردازش نیست.",
  429: "تعداد درخواست‌ها بیش از حد مجاز است.",
  431: "هدرهای درخواست بسیار بزرگ هستند.",
  451: "منبع مورد نظر به دلایل قانونی در دسترس نیست.",
  500: "خطای داخلی سرور.",
  501: "پشتیبانی نشده.",
  502: "خطای دروازه.",
  503: "سرویس در دسترس نیست.",
  504: "زمان اتصال به سرور گیتوی اتمام یافته است.",
  505: "نسخه HTTP پشتیبانی نمی‌شود.",
  507: "فضای ذخیره‌سازی کافی نیست.",
  508: "حلقه درون درخواست شناسایی شد.",
  510: "برخی افزونه‌های مورد نیاز مشخص نشده‌اند."
};
