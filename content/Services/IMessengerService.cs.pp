using System;

namespace $rootnamespace$.Services
{
	public interface IMessengerService
	{
		bool Send(string from, string to, string subject, string body, bool isBodyHtml);
	}
}