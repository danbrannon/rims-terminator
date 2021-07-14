# rims-terminator
This is a script intended to be run with automated deployments.  It queries the RIMS database to see if there's a Workstation/Terminal number associated with the currently logged-on user.

It requires a match between the users username and the description field in the RIMS Workstation table.  If there isn't a match (especially in the case where the computer is logged in with an administrator account) it doesn't make any changes.  It'll also generate an empty HKLM\Software\WOW6432Node\DAI\RIMS\ registry path if it doesn't exist.  So it CAN be run ahead of time safely.

It can also be run interactively to write the proper terminal number for a given user.  But this doesn't always work, as in the case where a Workstation's description is generic, etc.
