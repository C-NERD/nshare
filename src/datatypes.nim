type

    Locations = object
        downloads* : string
        document*, music*, video*, image* : seq[string]

    Extensions = object
        docext*, musicext*, videoext*, imageext* : seq[string]

    Settings* = object
        locations* : Locations
        extensions* : Extensions

    FileObj* = object
        name*, path*, ext* : string
