class ButtonLinkSchemeData
  SYSTEM_SCHEMES = Struct.new(:primary, :light, :link)

  SCHEME_MAP = SYSTEM_SCHEMES[
    "bg-primary text-white font-bold py-2 px-4 rounded text-sm",
    "text-dark py-2 px-2 rounded hover:text-primary hover:font-bold text-sm",
    "bg-transparent text-primary font-bold py-2 px-4 rounded hover:bg-gray-100 text-sm"
  ]
end
