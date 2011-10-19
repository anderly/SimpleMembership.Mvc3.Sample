using System;
using System.Net.Mail;

namespace $rootnamespace$.Services
{
	public class MessengerService : IMessengerService
	{
		#region IMessengerService Members

		public bool Send(string from, string to, string subject, string body, bool isBodyHtml)
		{
			var isSuccess = false;
			
			try
			{
				var msg = new MailMessage(from, to, subject, body);
				msg.IsBodyHtml = isBodyHtml;
				var smtp = new SmtpClient();
				smtp.Send(msg);
				isSuccess = true;
			}
			catch (Exception ex)
			{
				//Log exception
			}
		
			return isSuccess;
		}

		#endregion
	}
}