# Yie Ar Kung-Fu II - The Emperor Yie-Gah (Konami, MSX1) - desensamblado
#
# El orden de las cosas: trazar el flujo -> generar el listado -> comprobar que
# vuelve a dar la ROM byte a byte -> las comprobaciones que el reensamblado NO
# cubre.
#
# El cartucho no se distribuye: hace falta en la raiz como yiear2.rom, y
# `make comprueba` verifica su sha256.

ROM      = yiear2.rom
SHA      = bcb41b35ec0dddfd81ee9bd46998c0ea9c9435d6292e973d46c1324cc36e6150
SRC      = src
WORK     = work
ORG      = 0x4000
TITULO   = YIE AR KUNG-FU II: THE EMPEROR YIE-GAH - Konami - MSX1 - cartucho RC-737 de 32 KB en las paginas 1 y 2

all: listado verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " Falta $(ROM), y este repositorio NO lo distribuye."
	@echo ""
	@echo " Es Yie Ar Kung-Fu II (Konami, RC-737) para MSX, 32768 bytes exactos."
	@echo " Ponlo aqui con ese nombre. Para comprobar que es el mismo:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo "=================================================================="
	@false

comprueba: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# El trazado sigue el flujo desde los puntos de entrada. Los que no se pueden
# deducir estaticamente -ganchos de interrupcion, destinos de saltos
# indirectos- estan declarados en el .entries, cada uno con su justificacion.
$(WORK)/yiear2.trace.json: $(ROM) $(SRC)/yiear2.entries $(SRC)/yiear2.nocode
	@mkdir -p $(WORK)
	python3 tools/z80trace.py $(ROM) $(ORG) $(SRC)/yiear2.entries \
	        $(WORK)/yiear2 $(SRC)/yiear2.nocode

trace: $(WORK)/yiear2.trace.json

listado: $(WORK)/yiear2.trace.json $(SRC)/yiear2.notes
	python3 tools/mkasm.py $(ROM) $(ORG) $(WORK)/yiear2.trace.json \
	        $(SRC)/yiear2.notes work/msx.sym $(SRC)/yiear2.asm "$(TITULO)"

# La prueba que decide si el desensamblado es fiable.
verify: $(SRC)/yiear2.asm $(ROM)
	@sh tools/verify_build.sh $(SRC)/yiear2.asm $(ROM) $(ORG)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. El binario sale identico igual, porque los bytes no cambian; lo unico
# que cambia es lo que decimos de ellos.
sanity: $(WORK)/yiear2.trace.json
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@python3 tools/check_trace.py $(WORK)/yiear2.trace.json $(SRC)/yiear2.nocode
	@python3 tools/check_datos_como_codigo.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@python3 tools/check_entradas.py $(SRC)/yiear2.entries $(SRC)/yiear2.notes \
	        $(SRC)/yiear2.nocode
	@echo "=================================================================="
	@echo " ni un byte del cartucho sin asignar"
	@echo "=================================================================="
	@python3 tools/presupuesto.py $(WORK) $(SRC)

densidad:
	@python3 tools/densidad.py $(SRC)/yiear2.asm

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# Las imagenes, montadas ejecutando en Python los pasos del cartucho. No hay ni
# una captura de pantalla en este repositorio.
imagenes: $(ROM)
	@mkdir -p work/gfx
	python3 tools/graficos.py $(ROM) $(ORG) work/gfx
	python3 tools/figuras.py $(ROM) work/gfx

# Y la comprobacion de que esas imagenes son las de verdad: se deja correr el
# cartucho en openMSX, se vuelca su VRAM y se compara BYTE A BYTE. Mirar el
# dibujo no basta.
OPENMSX = C:/Program Files/openMSX/openmsx.exe
vram: $(ROM)
	@rm -rf work/omsx && mkdir -p work/omsx
	"$(OPENMSX)" -machine Philips_VG_8020 -cart $(ROM) -script tools/omsx_vram.tcl
	@python3 tools/coteja_vram.py $(ROM) $(ORG) work/omsx

# Y la sonda, que es de donde salen los instantes que usa el volcado.
sonda: $(ROM)
	@mkdir -p work/omsx
	"$(OPENMSX)" -machine Philips_VG_8020 -cart $(ROM) -script tools/omsx_sonda.tcl
	@cat work/omsx/sonda.txt

# LA WEB
#
# Bilingue: el ingles en docs/ y el castellano en docs/es/. Las paginas se
# escriben en markdown y se convierten con md2html.py; la portada la monta
# make_web.py, que declara las cifras medidas de ESTE cartucho.
#
# Las imagenes se REHACEN aqui, no se copian a mano: si una herramienta de
# dibujo se queda fuera de este target, la lamina se queda vieja sin que nadie
# proteste.
web: $(ROM)
	@mkdir -p docs/imagenes
	python3 tools/graficos.py $(ROM) $(ORG) docs/imagenes
	python3 tools/figuras.py $(ROM) docs/imagenes
	python3 tools/md2html.py docs en
	python3 tools/md2html.py docs/es es
	python3 tools/make_web.py docs/imagenes docs/index.html en
	python3 tools/make_web.py docs/imagenes docs/es/index.html es
	python3 tools/check_enlaces.py docs

clean:
	rm -rf $(WORK)/yiear2.trace.json $(WORK)/yiear2.blocks

.PHONY: all comprueba trace listado verify sanity test densidad imagenes vram sonda web clean
