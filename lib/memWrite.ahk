memWrite(jp, en, loopCount := "1", menu_start_addr := "0x46000000", menu_end_addr := "0x50000000")
{
  loop, %loopCount%
  {
    menuAOB := dqx.hexStringToPattern(jp)
    menuAddress := dqx.processPatternScan(menu_start_addr, menu_end_addr, menuAOB*)

    if (%loopCount% > 1)
    {
      menuAddress := menuAddress + 1
    }

    menuAddress := dqx.processPatternScan(menuAddress,,menuAOB*)
    dqx.writeBytes(menuAddress, en)
  }
}
