.title "data segment"

.area DATA(REL, CON)
P_LEDLOC == . 	;That's a define!

.db P_LED_R, P_LED_Y, P_LED_G, P_LED_B
