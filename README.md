# Win-Roaming-Profile-DEL

## What is this for?
Win-Roaming-Profile-DEL was created as a result of quickly and efficiently needing to wipe out a profile across a series of servers to remove the NTUSER.dat and related registry entries.
This will primarily benefit old profiles which may have been corrupted due to migrations, network instability, etc.

## What should I know?
The deletion of profiles is geared towards roaming profiles and folder redirect being separate. It could still be adopted to most environments but will necessitate either a manual migration of user data or fork of the scripts design.
The registry deletion WILL RETURN ERRORS under most circumstances. That is totally fine, a user could have no registry keys on a specific server. Remain attentive to what the errors return.

## Are these scripts dangerous?
Like any script involving DELETIONS be mindful of what you are doing. Triple check your work, then execute. There is nothing implemented by means of confirmation or fact checking; you are the driver.