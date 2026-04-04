#
#  This software has been developed by TIXEO.
#
#  Copyright (c) 2004-2024 TIXEO - All Rights Reserved.
#
#  COPYRIGHT:
#   This file is the property of TIXEO. 
#   It can not be used, modified, copied without the explicit written
#   authorization from a mandated member of TIXEO.
#
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#  WARRANTY:
#    This software is provided "AS IS" and any express or implied warranties,
#    including, but not limited to, the implied warranties of merchantability and
#    fitness for a particular purpose are disclaimed. In no no event shall copyright
#    holders be liable for any direct, indirect, incidental, special, exemplary
#    or consequential damages (including, but not limited to, procurement of 
#    substitute goods or services; loss of use, data, or profits; or business
#    interruption) however caused and on any theory of liability, whether in
#    contract, strict liability, or tort (including negligence or otherwise)
#    arising in any way out of the use of this software, even if advised or the
#    possibility of such damage.
#

# Default's path for the current free pascal compiler, 
# but can be overridden by an environment variable
FPC_PATH?=/tbt/fpc/fpc-3.3.1
#
# Allow to specify the webidl2pas to be used.
#
WEBIDL2PAS?=$(FPC_PATH)/bin/webidl2pas
#
# Allow to specify pas2js installation dir
#
PAS2JSDIR?=/home/$(USER)/tixeo/pas2js/
#
# Allow to specify pas2js installation dir
#
WEBASSEMBLY_UTILS?=/home/$(USER)/tixeo/webassembly-utils
#
# Allow to skip generation of job_web.webidl
#
JOB_WEB_DEPS=job_webalias.txt job_webglobals.txt 
ifndef SKIP_WEBIDL
JOB_WEB_DEPS:=$(JOB_WEB_DEPS) job_web.webidl
endif

all: wasisimpletest.wasm index.html webserver

index.html: hostsimpletest.js

hostsimpletest.js: hostsimpletest.lpr job_browser.pp
	@echo "-------------------------------------------------------"
	@echo " - Generating hostsimpletest.js"
	@echo "-------------------------------------------------------"
	$(FPC_PATH)/bin/pas2js hostsimpletest.lpr -Jc -Jirtl.js

wasisimpletest.wasm: wasmsimpletest.lpr Wasm.Job.Js.pas Wasm.Job.Shared.pas job.js.pas job.shared.pas
	@echo "-------------------------------------------------------"
	@echo " - Generating wasmsimpletest.wasm "
	@echo "-------------------------------------------------------"
	$(FPC_PATH)/bin/fpc -tunicodertl-browser -dFPC_DOTTEDUNITS -Twasi -Pwasm32 wasmsimpletest.lpr -owasmsimpletest.wasm

webserver: index.html wasmsimpletest.wasm index.html bulma.min.css
	@echo "-------------------------------------------------------"
	@echo " - Running webserver ..."
	@echo "-------------------------------------------------------"
	python3 -m http.server

check:
	@echo "-------------------------------------------------------"
	@echo " - Checking if mandatory tools are installed ... "
	@echo "-------------------------------------------------------"
    @which fpc > /dev/null || (echo "Error: fpc compiler is not installed or not available in PATH"; exit 1)
	@which pas2js > /dev/null || (echo "Error: pas2js is not installed or not available in PATH"; exit 1)
	@which webidl2pas > /dev/null || (echo "Error: webidl2pas is not installed or not available in PATH"; exit 1)

clean:
	@echo "-------------------------------------------------------"
	@echo " - Cleaning old files "
	@echo "-------------------------------------------------------"
	@rm -f *.o
	@rm -f *.ppu
	#@rm -f *.js
	#@rm -f job_web
	#@rm -f job_web.pas
	#@rm -f *.wasm
	#@rm -f job_shared.pp
	#@rm -f job_browser.pp
	@rm -f BrowserTixeoDom.js
	@rm -f WasiTixeoDom.wasm

.PHONY: all clean check
