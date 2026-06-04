If the barcode scanner is from any brand other than Urovo
it must be configured with custom Intent:
Intent action : "com.android.serial.BARCODEPORT_RECEIVEDDATA_ACTION"
Extra decode string value = "DATA" (note:this is key of Inent ,do not repeat this value for oher keys) 