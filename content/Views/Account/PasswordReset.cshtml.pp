﻿﻿@model $rootnamespace$.Models.PasswordResetModel

@{
    ViewBag.Title = "Password Reset";
}

<h2>Password Reset</h2>

<script src="@Url.Content("~/Scripts/jquery.validate.min.js")" type="text/javascript"></script>
<script src="@Url.Content("~/Scripts/jquery.validate.unobtrusive.min.js")" type="text/javascript"></script>

@using (Html.BeginForm()) {
        @Html.ValidationSummary(true, "Password reset was unsuccessful. Please correct the errors and try again.")
    <div>
                <div class="editor-label">
                @Html.LabelFor(m => m.ResetToken)
            </div>
            <div class="editor-field">
                @Html.TextBoxFor(m => m.ResetToken, new { @Value = @Request.QueryString["resetToken"]})
                @Html.ValidationMessageFor(m => m.ResetToken)
            </div>

            <div class="editor-label">
                @Html.LabelFor(m => m.NewPassword)
            </div>
            <div class="editor-field">
                @Html.TextBoxFor(m => m.NewPassword)
                @Html.ValidationMessageFor(m => m.NewPassword)
            </div>

            <div class="editor-label">
                @Html.LabelFor(m => m.ConfirmPassword)
            </div>
            <div class="editor-field">
                @Html.TextBoxFor(m => m.ConfirmPassword)
                @Html.ValidationMessageFor(m => m.ConfirmPassword)
            </div>

            <p>
                <input type="submit" value="Change Password" />
            </p>
    </div>
}