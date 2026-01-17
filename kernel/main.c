#include "../include/lib/print.h"
#include "../include/kernel/init.h"
#include "../include/kernel/debug.h"
int main(void) {
   put_str("I am kernel\n");
   init_all();
   ASSERT(1==2);
   while(1);
   return 0;
}

