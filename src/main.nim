import std/[logging,os]
import argparse
import bkm

let logform = "[$time] $levelname: "
var consoleLog = newConsoleLogger(fmtStr=logform)
var rollingLog = newRollingFileLogger(filename="bkm.log", fmtStr=logform,)
addHandler(consoleLog)
addHandler(rollingLog)

var p = newParser:
  help("bkm - beckx konto manager, to manage my money - enjoy")
  # flag("-n", "--dryrun", help="running dry...")
  # option("-o", "--output", help="this is the output option...", default=some("foobar.txt"))
  # option("-o", "--output", help="this is the output option...")
  # arg("input") # if this is set: this argument has to be given for the app; it is mandatory
  command("import"):
    help("import csv-file to bkm-data")
    arg("files", help="imports one or more files; if no argument is given for files, tries to import csv-files from current dir", nargs = -1)

# proc flagDryrun()
# proc optionOutput(s: string)
proc cmdImport(args: seq[string])
  
when isMainModule:
  var files: seq[string] = @[]
  try:
    var opts = p.parse()
    # if opts.dryrun:
    #   flagDryrun()
    # if opts.output != "":
    #   echo "list command"
    #   optionOutput(opts.output)
    # if opts.input != "":
    #   echo opts.input
    if opts.import.isSome():
      for file in opts.import.get.files:
        files.add(expandFilename(file))
      if len(files) == 0:
        files.add(expandFilename("."))
      cmdImport(files)
  except ShortCircuit as err:
    if err.flag == "argparse_help":
      echo err.help
      quit(1)
  except UsageError:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)

proc cmdImport(args: seq[string]) =
  importFiles(args)
