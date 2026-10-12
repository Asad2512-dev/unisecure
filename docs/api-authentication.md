# API authentication

Mobile authentication uses Laravel Sanctum personal access tokens. Provisioned users log in with existing credentials; clients cannot register accounts or choose roles. `status=active` is required to issue a token. Logout deletes only the current token. Admin web login remains session-based and is not replaced by mobile tokens.

Use HTTPS in deployment, keep bearer tokens out of logs and source control, and rotate/revoke tokens through an authorized operational process. OTP is not part of the authentication architecture.
