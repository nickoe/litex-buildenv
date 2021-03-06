from litex.soc.integration.soc_core import mem_decoder

from liteeth.phy.model import LiteEthPHYModel
from liteeth.core.mac import LiteEthMAC

from targets.utils import dict_set_max
from targets.sim.base import BaseSoC


class NetSoC(BaseSoC):
    mem_map = {**SoCSDRAM, **{
        "ethmac": 0xb0000000
    }}

    def __init__(self, *args, **kwargs):
        # Need a larger integrated ROM to fit the BIOS with TFTP support.
        dict_set_max(kwargs, 'integrated_rom_size', 0x10000)

        BaseSoC.__init__(self, *args, **kwargs)

        self.submodules.ethphy = LiteEthPHYModel(self.platform.request("eth"))
        # FIXME: The sim seems to require ethphy at 18 and ethmac at 19!?
        self.add_csr("ethphy", csr_id=18)
        self.submodules.ethmac = LiteEthMAC(phy=self.ethphy, dw=32, interface="wishbone", endianness=self.cpu.endianness)
        self.add_wb_slave(self.mem_map["ethmac"], self.ethmac.bus)
        self.add_csr("ethmac", csr_id=19)
        self.add_memory_region("ethmac", self.mem_map["ethmac"], 0x2000, type="io")

        self.add_interupt("ethmac")

    def configure_iprange(self, iprange):
        iprange = [int(x) for x in iprange.split(".")]
        while len(iprange) < 4:
            iprange.append(0)
        # Our IP address
        self._configure_ip("LOCALIP", iprange[:-1]+[50])
        # IP address of tftp host
        self._configure_ip("REMOTEIP", iprange[:-1]+[100])

    def _configure_ip(self, ip_type, ip):
        for i, e in enumerate(ip):
            s = ip_type + str(i + 1)
            s = s.upper()
            self.add_constant(s, e)


SoC = NetSoC
