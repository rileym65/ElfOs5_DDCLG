PROJECT = ddclg
INCDIR = ../../Include
OBJS = \
	abs.prg \
	buildmaze.prg \
	checkstep.prg \
	convertcoord.prg \
	drawmap.prg \
	init.prg \
	mazecheck.prg \
	movedragon.prg \
	offset.prg \
	playerturn.prg \
	rnd.prg \
	main.prg

.SUFFIXES: .asm .prg

$(PROJECT).bin: $(OBJS)
	link02 @ddclg.lnk -s -S symbols.sym -e -o $(PROJECT).bin

.asm.prg:
	asm02 -l -L -I$(INCDIR) $<

lists:
	adjlst buildmaze.lst buildmaze
	adjlst init.lst init
	adjlst mazecheck.lst mazecheck
	adjlst movedragon.lst movedragon

clean:
	-rm *.prg
	-rm *.lst
	-rm $(PROJECT).bin

install: $(PROJECT).bin
	cp $(PROJECT).bin ../../Image/games/
