//since api response with lower cased string 
//I could not use camelCased style
enum ScanResponses {
  ok,
  notfound,
  notstarted,
  duplicate,
  otherorder,
  disconnect,
  error,
  disabled,
  followerror,
  blocked,
  limiterror,
  notexist,
  returnererror, //for returning orders
  unIndentified
}
