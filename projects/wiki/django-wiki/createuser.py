#!/usr/bin/env python3
# ------------------------------------------------ #
## \file createuser.py
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ------------------------------------------------ #
from django.contrib.auth.models import User, Permission
import sys

try:
    u = User.objects.get(username=user)
    u.set_email(mail)
    u.set_password(password)
except:
    u = User.objects.create_user(user, mail, password)
u.user_permissions.add(Permission.objects.get(codename='add_wikipage'))
u.user_permissions.add(Permission.objects.get(codename='add_revision'))
u.user_permissions.add(Permission.objects.get(codename='change_wikipage'))
u.user_permissions.add(Permission.objects.get(codename='change_revision'))
u.save()
