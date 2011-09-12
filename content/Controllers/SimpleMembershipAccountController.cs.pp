using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using $rootnamespace$.Models;
using $rootnamespace$.Services;
using System.Net.Mail;

namespace $rootnamespace$.Controllers
{
	public class AccountController : Controller
	{
		public IWebSecurityService WebSecurityService { get; set; }

		protected override void Initialize(RequestContext requestContext)
		{
			if (WebSecurityService == null) { WebSecurityService = new WebSecurityService(); }

			base.Initialize(requestContext);
		}

		// **************************************
		// URL: /Account/LogOn
		// **************************************

		public ActionResult LogOn()
		{
			return View();
		}

		[HttpPost]
		public ActionResult LogOn(LogOnModel model, string returnUrl)
		{
			if (ModelState.IsValid)
			{
				if (WebSecurityService.Login(model.UserName, model.Password, model.RememberMe))
				{
					if (Url.IsLocalUrl(returnUrl))
					{
						return Redirect(returnUrl);
					}
					else
					{
						return RedirectToAction("Index", "Home");
					}
				}
				else
				{
					ModelState.AddModelError("", "The user name or password provided is incorrect.");
				}
			}

			// If we got this far, something failed, redisplay form
			return View(model);
		}

		// **************************************
		// URL: /Account/LogOff
		// **************************************

		public ActionResult LogOff()
		{
			WebSecurityService.Logout();

			return RedirectToAction("Index", "Home");
		}

		// **************************************
		// URL: /Account/Register
		// **************************************

		public ActionResult Register()
		{
			ViewBag.PasswordLength = WebSecurityService.MinPasswordLength;
			return View();
		}

		[HttpPost]
		public ActionResult Register(RegisterModel model)
		{
			if (ModelState.IsValid)
			{
				// Attempt to register the user
				bool requireEmailConfirmation = true;
				var token = WebSecurityService.CreateUserAndAccount(model.UserName, model.Password, null, requireEmailConfirmation);

				if (requireEmailConfirmation)
				{
					string hostUrl = Request.Url.GetComponents(UriComponents.SchemeAndServer, UriFormat.Unescaped);
					string confirmationUrl = hostUrl + VirtualPathUtility.ToAbsolute("~/Account/Confirm?confirmationCode=" + HttpUtility.UrlEncode(token));

					MailMessage msg = new MailMessage("yourEmailAddress", model.Email);
					msg.Subject = "Thanks for registering but first you need to confirm your registration...";
					msg.Body = "Your confirmation code is: " + token + ". Visit <a href=\"" + confirmationUrl + "\">" + confirmationUrl + "</a> to activate your account.";
					msg.IsBodyHtml = true ;

					SmtpClient smtp = new SmtpClient();
					smtp.Send(msg);

					// Thank the user for registering and let them know an email is on its way
					return RedirectToAction("Thanks", "Account");
				}
				else
				{
					// Navigate back to the homepage and exit
					WebSecurityService.Login(model.UserName, model.Password);
					return RedirectToAction("Index", "Home");
				}
			}

			// If we got this far, something failed, redisplay form
			ViewBag.PasswordLength = WebSecurityService.MinPasswordLength;
			return View(model);
		}

		public ActionResult Confirm()
		{
			string confirmationToken = Request.QueryString["confirmationCode"];
			WebSecurityService.Logout();
	
			if (!string.IsNullOrEmpty(confirmationToken)) 
			{
				if (WebSecurityService.ConfirmAccount(confirmationToken)) 
				{
					ViewBag.Message = "Registration Confirmed! Click on the login link at the top right of the page to continue.";
				} else {
				ViewBag.Message = "Could not confirm your registration info";
				}
			}
			
			return View();
		}

		// **************************************
		// URL: /Account/ChangePassword
		// **************************************

		[Authorize]
		public ActionResult ChangePassword()
		{
			ViewBag.PasswordLength = WebSecurityService.MinPasswordLength;
			return View();
		}

		[Authorize]
		[HttpPost]
		public ActionResult ChangePassword(ChangePasswordModel model)
		{
			if (ModelState.IsValid)
			{
				if (WebSecurityService.ChangePassword(User.Identity.Name, model.OldPassword, model.NewPassword))
				{
					return RedirectToAction("ChangePasswordSuccess");
				}
				else
				{
					ModelState.AddModelError("", "The current password is incorrect or the new password is invalid.");
				}
			}

			// If we got this far, something failed, redisplay form
			ViewBag.PasswordLength = WebSecurityService.MinPasswordLength;
			return View(model);
		}

		public ActionResult ForgotPassword()
		{
			return View();
		}

		[HttpPost]
		public ActionResult ForgotPassword(ForgotModel model)
		{
			bool isValid = false;
			string resetToken="";

			if (ModelState.IsValid)
			{
				if (WebSecurityService.GetUserId(model.UserName) > -1 && WebSecurityService.IsConfirmed(model.UserName))
				{
					resetToken = WebSecurityService.GeneratePasswordResetToken(model.UserName);
					isValid = true;
				}

				if (isValid)
				{
					string hostUrl = Request.Url.GetComponents(UriComponents.SchemeAndServer, UriFormat.Unescaped);
					string resetUrl = hostUrl + VirtualPathUtility.ToAbsolute("~/Account/PasswordReset?resetToken=" + HttpUtility.UrlEncode(resetToken));

					MailMessage msg = new MailMessage("yourEmailAddress", model.Email);
					msg.Subject = "Password reset request";
					msg.Body = "Use this password reset token to reset your password. <br/>The token is: " + resetToken + "<br/>Visit <a href='" + resetUrl + "'>" + resetUrl + "</a> to reset your password.<br/>";
					msg.IsBodyHtml = true;

					SmtpClient smtp = new SmtpClient();
					smtp.Send(msg);
				}
				return RedirectToAction("ForgotPasswordMessage");
			}
			return View(model);
		}

		public ActionResult ForgotPasswordMessage()
		{
			return View();
		}

		public ActionResult PasswordReset()
		{
			return View();
		}

		[HttpPost]
		public ActionResult PasswordReset(PasswordResetModel model)
		{
			if (ModelState.IsValid)
			{
				if (WebSecurityService.ResetPassword(model.ResetToken, model.NewPassword))
				{
					return RedirectToAction("PasswordResetSuccess");
				}
				else
				{
					ModelState.AddModelError("","The password reset token is invalid.");
				}
			}

			return View(model);
		}

		public ActionResult PasswordResetSuccess()
		{
			return View();
		}


		// **************************************
		// URL: /Account/ChangePasswordSuccess
		// **************************************

		public ActionResult ChangePasswordSuccess()
		{
			return View();
		}

		public ActionResult Thanks()
		{
			return View();
		}

	}
}
