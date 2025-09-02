class AppConstants {
  static const String baseUrl = "https://crmdbsoft.zeabur.app";
  static const String loginEndpoint = "$baseUrl/login";
  static const String registerEndpoint = "$baseUrl/auth/register";
  static const String customerCreateEndpoint = "$baseUrl/customerCreate";
  static const String worksGetAllEndpoint = "$baseUrl/works";
  static const String workCreateEndpoint = "$baseUrl/workCreate";
  // Meetings
  static const String meetingsEndpoint = "$baseUrl/meetings"; // GET all, PUT/DELETE /:id
  static const String meetingCreateEndpoint = "$baseUrl/meetings"; // POST create
  static const String meetingsByUsernameEndpoint = "$baseUrl/meetings/username"; // + /:username
}
