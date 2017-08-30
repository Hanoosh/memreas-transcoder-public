#!/bin/bash
#Purpose = pull from git and copy back server constants

cp module/Application/src/Application/Model/MemreasConstants.php module/Application/src/Application/Model/MemreasConstants.server.php
git pull
cp module/Application/src/Application/Model/MemreasConstants.server.php module/Application/src/Application/Model/MemreasConstants.php

