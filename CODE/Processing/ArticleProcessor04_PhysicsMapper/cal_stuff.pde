
// CALENDAR FUNCTIONS

Calendar thisCalDate;
DateFormat format;
Date myDate;

public Calendar makeCalFromTime(String dataTimeIn) {
  // 01/05/2014 00:00:02
  // dd/MM/yyyy HH:mm:ss ... copy and format the excel cells with this custom format
  //format = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss"); // see http://www.roseindia.net/java/java-conversion/StringToDate.shtml
  // from userActivities: 
  //  2014-10-31T05:00:00Z
  // from sleep:
  //  2014-11-19T07:10:48.7997221Z
  // from run:
  //  2014-11-22T01:58:13.5052098Z
  // see http://docs.oracle.com/javase/6/docs/api/java/text/SimpleDateFormat.html
  format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
  myDate = new Date();
  try {
    myDate = format.parse(dataTimeIn);
  } // end try
  catch(Exception e) {
    //println("#");
    return null;
  } // end catch
  thisCalDate = Calendar.getInstance();
  thisCalDate.setTime(myDate);
  return thisCalDate;
} // end getCalFromMeetingResponseDataTime 



//
public long getMSFromTime( String dataTimeIn) {
  return getMSFromTime(dataTimeIn, 0);
} // end getMSFromTime

//
public long getMSFromTime(String dataTimeIn, int timeZoneShift) {
  thisCalDate = makeCalFromTime(dataTimeIn);
  if (timeZoneShift != 0) thisCalDate.add(Calendar.HOUR_OF_DAY, timeZoneShift);
  if (thisCalDate == null) return 0;
  return thisCalDate.getTimeInMillis();
} // end getMSFromTime



//
// return a calendar that is just the day
public Calendar stripToDay(Calendar cal) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  //format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
  return makeCalFromTime(nf(cal.get(Calendar.YEAR), 4) + "-" + nf(cal.get(Calendar.MONTH) + 1, 2)+ "-" + nf(cal.get(Calendar.DAY_OF_MONTH), 2) + "T00:00:00");
} //end stripToDay

//


//
public String getFormatTime(Calendar c) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  if (c == null) c = Calendar.getInstance();
  return format.format(c.getTime());
} // end getFormatTime

//
String getNiceTimeString(Calendar c) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  return c.get(Calendar.YEAR) + "/" + nf((c.get(Calendar.MONTH) + 1), 2) + "/" + nf(c.get(Calendar.DAY_OF_MONTH), 2) + "  " + nf(c.get(Calendar.HOUR_OF_DAY), 2) + ":" + nf(c.get(Calendar.MINUTE), 2) + ":" + nf(c.get(Calendar.SECOND), 2);
} // end getNiceTimeString

//
String getNiceTimeString(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return  getNiceTimeString(thisCalDate);
} // end getNiceTimeString


//
String getNiceTimeStringSimple(Calendar c) {
  return c.get(Calendar.YEAR) + "/" + nf((c.get(Calendar.MONTH) + 1), 2) + "/" + nf(c.get(Calendar.DAY_OF_MONTH), 2);
} // end getNiceTimeString
//
String getNiceTimeStringSimpleWithHour(Calendar c) {
  return c.get(Calendar.YEAR) + "/" + nf((c.get(Calendar.MONTH) + 1), 2) + "/" + nf(c.get(Calendar.DAY_OF_MONTH), 2) + "  " + nf(c.get(Calendar.HOUR_OF_DAY), 2);
} // end getNiceTimeStringSimpleWithHour

//
String getNiceTimeStringSimple(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return  getNiceTimeStringSimple(thisCalDate);
} // end getNiceTimeStringSimple

//
String getNiceTimeStringForMouseOverTimeline(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  String basicString = getNiceTimeStringSimple(thisCalDate);
  basicString = getDayOfWeek(thisCalDate.get(Calendar.DAY_OF_WEEK)) + ", " + basicString;
  return basicString;
} // end getNiceTimeStringForMouseOverTimeline

//
String getNiceTimeStringForCalendarTime(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return getDayOfWeek(thisCalDate.get(Calendar.DAY_OF_WEEK)) + ", " + getMonthOfYear(thisCalDate.get(Calendar.MONTH)) + " " + thisCalDate.get(Calendar.DAY_OF_MONTH) + ", " + thisCalDate.get(Calendar.YEAR) + " - " + nf(thisCalDate.get(Calendar.HOUR_OF_DAY), 2) + ":" + nf(thisCalDate.get(Calendar.MINUTE), 2);
} // end getNiceTimeStringForCalendarTime

//
String makeHourString(String dateTimeIn) {
  return split(dateTimeIn, ":")[0] + ":00:00";
} // end makeHourString

//
String makeDayString(String dateTimeIn) {
  return split(dateTimeIn, " ")[0];
} // end makeDayString

//
int getHourOfDay(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return thisCalDate.get(Calendar.HOUR_OF_DAY);
} // end getHourOfDay

//
String getDayOfWeek(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return getDayOfWeek(thisCalDate.get(Calendar.DAY_OF_WEEK));
} // end getDayOfWeek

//
String getDayOfWeek(int dayOfWeek) {
  switch(dayOfWeek) {
  case 1:
    return "Sunday";
  case 2: 
    return "Monday";
  case 3: 
    return "Tuesday";
  case 4:
    return "Wednesday";
  case 5:
    return "Thursday";
  case 6:
    return "Friday";
  case 7:
    return "Saturday";
  default:
    return "Unknown";
  } // end switch
} // end getDayOfWeek

//
String getMonthOfYear(int monthOfYear) {
  switch(monthOfYear) {
  case 0:
    return "January";
  case 1:
    return "February";
  case 2: 
    return "March";
  case 3: 
    return "April";
  case 4:
    return "May";
  case 5:
    return "June";
  case 6:
    return "July";
  case 7:
    return "August";
  case 8:
    return "September";
  case 9:
    return "October";
  case 10:
    return "November";
  case 11:
    return "December";
  default:
    return "Unknown";
  } // end switch
} // end getMonthOfYear

//
long convertHHMMSSToMS(String timeIn) {
  // assume that the time comes in as HH:MM:SS
  // 01/05/2014 00:00:02
  format = new SimpleDateFormat("HH:mm:ss"); // see http://www.roseindia.net/java/java-conversion/StringToDate.shtml
  myDate = new Date();
  try {
    myDate = format.parse(timeIn);
  } // end try
  catch(Exception e) {
    //println("#");
    return -1l;
  } // end catch
  thisCalDate = Calendar.getInstance();
  thisCalDate.setTime(myDate);
  long thisTime = thisCalDate.getTimeInMillis();
  try {
    myDate = format.parse("00:00:00"); // set the 0 time
  }
  catch (Exception e) {
    return -1l;
  };
  thisCalDate.setTime(myDate);

  return (thisTime - thisCalDate.getTimeInMillis());
} // end convertHHMMSSToMS 


public long getDateDiff(long date1, long date2, TimeUnit timeUnit) {
  long diffInMillies = date2 - date1;
  return timeUnit.convert(diffInMillies, TimeUnit.MILLISECONDS);
} // end getDateDiff

//
// find out how many days are between the end ms and start ms
public float getDaysBetweenMS(long msStart, long msEnd) {
  float diff = (msEnd - msStart);
  diff /= (1000 * 24 * 60 * 60);
  return diff;
} // end getDaysBetweenMS


//
// reduce to midnight of the sunday before this calendar date
public Calendar reduceToWeekStart(Calendar c) {
  Calendar modifiedCalendar = Calendar.getInstance();
  long msHMS = c.get(Calendar.HOUR_OF_DAY) * 1000 * 60 * 60 + c.get(Calendar.MINUTE) * 1000 * 60 + c.get(Calendar.SECOND) * 1000;
  int dayOfWeek = c.get(Calendar.DAY_OF_WEEK) - 1;
  long newMS = c.getTimeInMillis() - msHMS - dayOfWeek * 24 * 1000 * 60 * 60;
  modifiedCalendar.setTimeInMillis(newMS);
  return modifiedCalendar;
} // end reduceToWeekStart 

//
// reduce to midnight of the first of the month before this calendar date
public Calendar reduceToMonthStart(Calendar c) {
  Calendar modifiedCalendar = Calendar.getInstance();
  long msHMS = c.get(Calendar.HOUR_OF_DAY) * 1000 * 60 * 60 + c.get(Calendar.MINUTE) * 1000 * 60 + c.get(Calendar.SECOND) * 1000;
  long dayOfMonth = c.get(Calendar.DAY_OF_MONTH) - 1;
  println("dayOfMonth as: " + dayOfMonth);
  long newMS = c.getTimeInMillis() - msHMS - dayOfMonth * 24 * 1000 * 60 * 60;
  modifiedCalendar.setTimeInMillis(newMS);
  return modifiedCalendar;
} // end reduceToCalendarStart


//
public float getRadiansFromHourMinute(long ms) {
  if (thisCalDate == null) thisCalDate = Calendar.getInstance();
  thisCalDate.setTimeInMillis(ms);
  return getRadiansFromHourMinute(thisCalDate);
} // end getRadiansFromHourMinute
//
// this will simply return a radian from the hour/minute of a calendar.  up as midnight
public float getRadiansFromHourMinute(Calendar c) {
  float rad = -HALF_PI;
  float hour = c.get(Calendar.HOUR_OF_DAY);
  float minute = c.get(Calendar.MINUTE);
  rad = map(hour * 60 + minute, 0, 24 * 60, 0, TWO_PI);
  //text(hour + ":" + minute + " -- " + (hour + minute), 20, 80);
  rad += HALF_PI;
  rad -= PI;
  return rad;
} // end getRadiansFromHourMinute

//
//
//
//
//
//

