memWrite(jp, en, jp_raw, en_raw, menu_start_addr := 0, menu_end_addr := 0)
{
  menuAOB := dqx.hexStringToPattern(jp)
  menuAddress := dqx.processPatternScan(menu_start_addr,menu_end_addr, menuAOB*)

  if (menuAddress != 0)
    dqx.writeBytes(menuAddress, en)
}
