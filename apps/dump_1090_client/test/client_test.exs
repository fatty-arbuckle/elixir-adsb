defmodule Dump1090Client.Network.ClientTest do
  use ExUnit.Case, async: true

  test "dump-1090: MSG,1" do
    rawMessage = "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0"
    expected = %Aircraft{
      icoa: "A44728",
      callsign: "JBU1616"
    }
    assert expected == Dump1090Client.Network.Client.parse_adsb(rawMessage)
  end

  test "dump-1090: MSG,3" do
    rawMessage = "MSG,3,,,AADFF1,,,,,,,40000,,,42.49749,-71.02463,,,0,0,0,0"
    expected = %Aircraft{
      icoa: "AADFF1",
      longitude: -71.02463,
      latitude: 42.49749,
      altitude: 40000
    }
    assert expected == Dump1090Client.Network.Client.parse_adsb(rawMessage)
  end

  test "dump-1090: MSG,4" do
    rawMessage = "MSG,4,,,A77C11,,,,,,,,397,251,,,0,,0,0,0,0"
    expected = %Aircraft{
      icoa: "A77C11",
      speed: 397,
      heading: 251
    }
    assert expected == Dump1090Client.Network.Client.parse_adsb(rawMessage)
  end
end
