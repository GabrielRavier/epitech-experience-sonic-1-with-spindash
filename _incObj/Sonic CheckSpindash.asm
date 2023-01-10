; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC3E:
Sonic_CheckSpindash:
        tst.b   spindash_flag(a0)
        bne.s   Sonic_UpdateSpindash
        cmpi.b  #id_Duck,obAnim(a0)
        bne.s   return_1AC8C
        move.b  (v_jpadpress2).w,d0
        andi.b  #$70,d0
        beq.w   return_1AC8C
        move.b  #9,obAnim(a0)
        move.w  #$E0,d0
        jsr     (PlaySound_Special).l
        addq.l  #4,sp
        move.b  #1,spindash_flag(a0)
        move.w  #0,$3A(a0)
        cmpi.b  #12,$28(a0)        ; if he's drowning, branch to not make dust
        blo.s   +
        move.b  #2,($FFFFD11C).w
+
        bsr.w   Sonic_LevelBound
        bsr.w   Sonic_AnglePos

return_1AC8C:
        rts
; End of subroutine Sonic_CheckSpindash


; ---------------------------------------------------------------------------
; Subrouting to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AC8E:
Sonic_UpdateSpindash:
	move.b	(v_jpadhold2).w,d0
	btst	#1,d0
	bne.w	Sonic_ChargingSpindash

	; unleash the charged spindash and start rolling quickly:
	move.b	#$E,y_radius(a0)
	move.b	#7,x_radius(a0)
	move.b	#2,obAnim(a0)
	addq.w	#5,y_pos(a0)	; add the difference between Sonic's rolling and standing heights
	move.b	#0,spindash_flag(a0)
	moveq	#0,d0
	move.b	$3A(a0),d0
	add.w	d0,d0
	move.w	SpindashSpeeds(pc,d0.w),obInertia(a0)
;	tst.b	(Super_Sonic_flag).w
;	beq.s	+
;	move.w	SpindashSpeedsSuper(pc,d0.w),obInertia(a0)
+
	; Determine how long to lag the camera for.
	; Notably, the faster Sonic goes, the less the camera lags.
	; This is seemingly to prevent Sonic from going off-screen.
	move.w	obInertia(a0),d0
	subi.w	#$800,d0 ; $800 is the lowest spin dash speed
    if 0
	; To fix a bug in 'ScrollHoriz', we need an extra variable, so this
	; code has been modified to make the delay value only a single byte.
	; The lower byte has been repurposed to hold a copy of the position
	; array index at the time that the spin dash was released.
	; This is used by the fixed 'ScrollHoriz'.
	lsr.w	#7,d0
	neg.w	d0
	addi.w	#$20,d0
	move.b	d0,($FFFFEED0).w
	; Back up the position array index for later.
	move.b	(Sonic_Pos_Record_Index+1).w,($FFFFEED0+1).w
    else
	add.w	d0,d0
	andi.w	#$1F00,d0 ; This line is not necessary, as none of the removed bits are ever set in the first place
	neg.w	d0
	addi.w	#$2000,d0
	move.w	d0,($FFFFEED0).w
    endif

	btst	#0,status(a0)
	beq.s	+
	neg.w	obInertia(a0)
+
	bset	#2,status(a0)
	move.b	#0,($FFFFD11C).w
	move.w	#$BC,d0	; spindash zoom sound
	jsr	(PlaySound_Special).l
	bra.s	Obj01_Spindash_ResetScr
; ===========================================================================
; word_1AD0C:
SpindashSpeeds:
	dc.w  $800	; 0
	dc.w  $880	; 1
	dc.w  $900	; 2
	dc.w  $980	; 3
	dc.w  $A00	; 4
	dc.w  $A80	; 5
	dc.w  $B00	; 6
	dc.w  $B80	; 7
	dc.w  $C00	; 8
; word_1AD1E:
SpindashSpeedsSuper:
	dc.w  $B00	; 0
	dc.w  $B80	; 1
	dc.w  $C00	; 2
	dc.w  $C80	; 3
	dc.w  $D00	; 4
	dc.w  $D80	; 5
	dc.w  $E00	; 6
	dc.w  $E80	; 7
	dc.w  $F00	; 8
; ===========================================================================
; loc_1AD30:
Sonic_ChargingSpindash:			; If still charging the dash...
	tst.w	$3A(a0)
	beq.s	+
	move.w	$3A(a0),d0
	lsr.w	#5,d0
	sub.w	d0,$3A(a0)
	bcc.s	+
	move.w	#0,$3A(a0)
+
	move.b	(v_jpadpress2).w,d0
	andi.b	#$70,d0
	beq.w	Obj01_Spindash_ResetScr
	move.w	#$900,obAnim(a0)
	move.w	#$E0,d0
	jsr	(PlaySound).l
	addi.w	#$200,$3A(a0)
	cmpi.w	#$800,$3A(a0)
	blo.s	Obj01_Spindash_ResetScr
	move.w	#$800,$3A(a0)

; loc_1AD78:
Obj01_Spindash_ResetScr:
	addq.l	#4,sp
	cmpi.w	#(224/2)-16,($FFFFEED8).w
	beq.s	loc_1AD8C
	bhs.s	+
	addq.w	#4,($FFFFEED8).w
+	subq.w	#2,($FFFFEED8).w

loc_1AD8C:
	bsr.w	Sonic_LevelBound
	bsr.w	Sonic_AnglePos
	rts
; End of subroutine Sonic_UpdateSpindash
