import 'dart:developer';

void warn(final String msg) => log(
      msg,
      name: 'Flutter Math',
      level: 900, // Level.WARNING
    );

void error(final String msg) => log(
      msg,
      name: 'Flutter Math',
      level: 1000, // Level.SEVERE
    );

void info(final String msg) => log(
      msg,
      name: 'Flutter Math',
      level: 800, // Level.INFO
    );
