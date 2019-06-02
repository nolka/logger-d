import std.stdio;
import std.algorithm.searching;
import std.exception;
import core.stdc.string : memset;

import logger;
import handlers;
import formatters;

void main()
{
    auto logger = new Logger();
    logger.addHandler(new StdoutHandler(new StandardFormatter()));
    logger.addHandler(new TextFileHandler("/tmp/kek.txt", new StandardFormatter()));

    logger.log("Hello");
}
