//import 'package:bitmap/bitmap.dart';
//
//class Event {
//  String id;
//   String name;
//   String eventPictureUrl;
//   String description;
//   DateTime startTime;
//   DateTime endTime;
//   var profilePicture;
//   var eventPicture;
//   List<Event> connectedEventList;
//   double latitude;
//   double longitude;
//   var attendingCount;
//   Event primaryEvent;
//
//  Event() {
//    connectedEventList = new List();
//  }
//
//  void addConnectedEvent(Event e) {
//    connectedEventList.add(e);
//  }
//
//  getProfilePicture() {
//    return profilePicture;
//  }
//
//  void setProfilePicture(var profilePicture) {
//    this.profilePicture = profilePicture;
//  }
//
//  String getName() {
//    return name;
//  }
//
//  void setName(String name) {
//    this.name = name;
//  }
//
//  void setEventPictureUrl(String eventPictureUrl) {
//    this.eventPictureUrl = eventPictureUrl;
//  }
//
//  String getDescription() {
//    return description;
//  }
//
//  void setDescription(String description) {
//    this.description = description;
//  }
//
//  DateTime getStartTime() {
//    return startTime;
//  }
//
//  void setStartTime(DateTime startTime) {
//    this.startTime = startTime;
//  }
//
//  void setEndTime(DateTime endTime) {
//    this.endTime = endTime;
//  }
//
//  getEventPicture() {
//    return eventPicture;
//  }
//
//  void setEventPicture(Bitmap eventPicture) {
//    this.eventPicture = eventPicture;
//  }
//
//  List<Event> getConnectedEventList() {
//    return connectedEventList;
//  }
//
//  double getLatitude() {
//    return latitude;
//  }
//
//  void setLatitude(double latitude) {
//    this.latitude = latitude;
//  }
//
//  double getLongitude() {
//    return longitude;
//  }
//
//  void setLongitude(double longitude) {
//    this.longitude = longitude;
//  }
//
//  Event getPrimaryEvent() {
//    return primaryEvent;
//  }
//
//  void setPrimaryEvent(Event primaryEvent) {
//    this.primaryEvent = primaryEvent;
//  }
//
//  getAttendingCount() {
//    return attendingCount;
//  }
//
//  void setAttendingCount(var attendingCount) {
//    this.attendingCount = attendingCount;
//  }
//
//  String getId() {
//    return id;
//  }
//
//  void setId(String id) {
//    this.id = id;
//  }
//
//}