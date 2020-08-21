.module dseg
.title "data segment"

;Def file includes
.include "define.def"
.include "macro.def"

.area DATA(REL, CON)
D_LEDLOC == . 	;That's a define!

.db P_LED_R, P_LED_Y, P_LED_G, P_LED_B

D_LEDPWM == . 	;That's a define!
.include "pwm_tbl.txt"
D_LEDPWM_LEN == . - D_LEDPWM