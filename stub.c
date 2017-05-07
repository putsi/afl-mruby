#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mruby.h>
#include <mruby/array.h>
#include <mruby/compile.h>
#include <mruby/dump.h>
#include <mruby/variable.h>

int main(int argc, char *argv[])
{
  if(argc < 2) { puts("Filename not supplied as param!"); exit(1); }

  mrb_state *mrb = mrb_open();
  if (!mrb) { puts("Could not get mrb!"); exit(1); }

  // Lets make it persistent.
  // This increases speed from 90/s to ~1200/s.
  while(__AFL_LOOP(1000))
  {
    FILE *f = fopen(argv[1], "r");
    mrb_load_file(mrb, f);
  }
  mrb_close(mrb);
  return 0;
}
