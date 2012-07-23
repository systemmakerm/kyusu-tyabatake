class SystemTest
  include Rhom::PropertyBag

  # 取得できるプロパティ名一覧
  PROPERTIES = [
    "platform",
    "has_camera",
    "screen_width",
    "screen_height",
    "screen_orientation",
    "ppi_x",
    "ppi_y",
    "has_network",
    "phone_number",
    "device_id",
    "phone_id",
    "full_browser",
    "device_name",
    "os_version",
    "locale",
    "country",
    "is_emulator",
    "has_calendar",
    "is_motorola_device"
  ]
  
end
