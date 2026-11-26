{ ... }:

{
  hardware.cpu.amd.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernelParams = [
    "amd_pstate=active"
  ];
}
