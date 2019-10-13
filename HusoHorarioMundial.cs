using System;
					
public class Program
{
	public static void Main()
	{
		var timezones = TimeZoneInfo.GetSystemTimeZones();
		var date1 = new DateTime(2019, 1, 15);
		var date2 = new DateTime(2019, 7, 15);
		
		Console.WriteLine(String.Format("{0,-62} {1,-32} {2,-32} {3,-15} {4,-20} {5,-20}", "Display Name", "Standard Name", "Daylight Name", "Supports DST", "UTC Standard Offset", "UTC Daylight Offset"));
		Console.WriteLine(String.Format("{0}", "".PadRight(186, '-')));
		
		foreach (var timezone in timezones)
		{
			var o1 = timezone.GetUtcOffset(date1);
			var o2 = timezone.GetUtcOffset(date2);
			var o1String = " 00:00";
			var o2String = " 00:00";
			
			if (o1 < TimeSpan.Zero)
				o1String = o1.ToString(@"\-hh\:mm");
			if (o1 > TimeSpan.Zero)
				o1String = o1.ToString(@"\+hh\:mm");
			if (o2 < TimeSpan.Zero)
				o2String = o2.ToString(@"\-hh\:mm");
			if (o2 > TimeSpan.Zero)
				o2String = o2.ToString(@"\+hh\:mm");

			Console.WriteLine(String.Format("{0,-62} {1,-32} {2,-32} {3,-15} {4,-20} {5,-20}", 
											timezone.DisplayName, 
											timezone.StandardName, 
											timezone.DaylightName, 
											timezone.SupportsDaylightSavingTime ? "Yes" : "No",
										    o1String,
										    o2String));
		}
	}
}