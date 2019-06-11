import std.stdio;
import std.conv;
import std.algorithm.searching;
import std.exception;
import core.stdc.string : memset;
import std.array;

import logger;
import handlers;
import formatters;

void main()
{
    auto logger = new Logger();
    logger.addHandler(new StdoutHandler(new StandardFormatter()));
    logger.addHandler(new TextFileHandler("/tmp/kek.txt", new StandardFormatter()));

    for (int i = 0; i < 15000; i++)
    {
        logger.log("Hello");
    }
    // logger.flush();

}
