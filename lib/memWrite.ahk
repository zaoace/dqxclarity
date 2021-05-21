memWrite(jp, en, jp_raw, en_raw, menu_start_addr := 0, menu_end_addr := 0)
{
  menuAOB := dqx.hexStringToPattern(jp)
  menuAddress := dqx.processPatternScan(menu_start_addr,menu_end_addr, menuAOB*)

  if (menuAddress == 0)
  {
    FileAppend, Not Found: JP: %jp_raw%  EN: %en_raw%`n,problem.txt
  }
  else
  {
    dqx.writeBytes(menuAddress, en)

      loop, 10
      {
        menuAddress := dqx.processPatternScan(menuAddress + 1, menu_end_addr, menuAOB*)

        if (menuAddress == 0)
        {
          FileAppend, Not Found: JP: %jp_raw%  EN: %en_raw%`n ,problem.txt
          break
        }

        dqx.writeBytes(menuAddress, en)
      }
    }
}