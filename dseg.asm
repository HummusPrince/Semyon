.title "data segment"

.area DATA(REL, CON)
D_LEDLOC == . 	;That's a define!

.db P_LED_R, P_LED_Y, P_LED_G, P_LED_B

D_LEDPWM == . 	;That's a define!

; pwmval, duration
.db 0x10, 0x20
.db 0x30, 0x48
.db 0x50, 0x30
.db 0x70, 0x20
.db 0x90, 0x14
.db 0xb0, 0x0c
.db 0xd0, 0x06
.db 0xf0, 0x02

D_LEDPWM_LEN == . - D_LEDPWM