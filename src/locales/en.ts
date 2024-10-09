export default {
  labels: {
    home: "Home",
  },
  theme: {
    base: {
      colorScheme: "Color Scheme",
    },
  },
  errors: {
    response: {
      not_json: {
        title: "Invalid Response",
        text: "The server returned an invalid response",
      },
    },
  },
  validation: {
    bad: "The value is not a valid {label}",
    notAFile: "Please select {label}",
    tooManyFiles: "Please select only 1 file",
    fileTooLarge: "The file you have selected is too large",
    invalidFileType:
      "The file you have selected is not an acceptable file type",
    fileTypeNotAccepted:
      "The file you have selected is not an acceptable file type",
    invalid: "Please enter your {label}",
    required: "Please enter your {label}",
    requiredSelection: "Please choose a {label}",
    requiredUpload: "Please select {label}",
    email: "Please enter a valid email address",
    min: "Your {label} must be at least {min} characters long",
    characters: "The {label} you have input contains invalid characters",
    invalidRsaId: "Please enter a valid {label}",
    country: "Please choose your country of residence",
    valid: "Please enter a valid {label}",
    alternatives: {
      all: "The value did not match all of the criteria.",
      any: "No alternative was found to test against the input due to try criteria.",
      match:
        "No alternative matched the input due to specific matching rules for at least one of the alternatives.",
      one: "The value matched more than one alternative schema.",
      types: "The provided input did not match any of the allowed types.",
    },
    any: {
      custom: "Please enter a valid {label}",
      default: "Please contact support",
      failover: "Please contact support",
      invalid: "The value matched a value listed in the invalid values.",
      only: "Only some values were allowed, the input didn't match any of them.",
      ref: "The input is not valid.",
      required: "A required value wasn't present.",
      unknown: "A value was present while it wasn't expected.",
    },
    boolean: {
      base: "{label} is required",
      accepted: "You must accept the {label}",
    },
    phone: {
      invalid: "Please enter a valid {label}",
      mobile: "Please enter a valid mobile number",
    },
    string: {
      alphanum: "{label} contains characters that are not alphanumeric.",
      alpha: "{label} contains non-alphabetic characters.",
      base: "{label} is required",
      country: "Please select a valid {label}",
      email: "Please enter a valid email.",
      empty: "{label} cannot be empty.",
      length: "{label} is not of the required length.",
      max: "{label} is longer than the maximum allowed length.",
      min: "{label} is shorter than the minimum allowed length.",
      pattern: {
        base: "{label} contains invalid characters.",
        name: "{label} contains invalid characters.",
        invert: {
          base: "{label} contains invalid characters.",
          name: "{label} contains invalid characters.",
        },
      },
    },
  },
  countries: {
    ad: "Andorra",
    ae: "United Arab Emirates",
    af: "Afghanistan",
    ag: "Antigua and Barbuda",
    ai: "Anguilla",
    al: "Albania",
    am: "Armenia",
    ao: "Angola",
    aq: "Antarctica",
    ar: "Argentina",
    as: "American Samoa",
    at: "Austria",
    au: "Australia",
    aw: "Aruba",
    ax: "Åland Islands",
    az: "Azerbaijan",
    ba: "Bosnia and Herzegovina",
    bb: "Barbados",
    bd: "Bangladesh",
    be: "Belgium",
    bf: "Burkina Faso",
    bg: "Bulgaria",
    bh: "Bahrain",
    bi: "Burundi",
    bj: "Benin",
    bl: "Saint Barthélemy",
    bm: "Bermuda",
    bn: "Brunei Darussalam",
    bo: "Bolivia, Plurinational State of",
    bq: "Bonaire, Sint Eustatius and Saba",
    br: "Brazil",
    bs: "Bahamas",
    bt: "Bhutan",
    bv: "Bouvet Island",
    bw: "Botswana",
    by: "Belarus",
    bz: "Belize",
    ca: "Canada",
    cc: "Cocos (Keeling) Islands",
    cd: "Congo, Democratic Republic of the",
    cf: "Central African Republic",
    cg: "Congo",
    ch: "Switzerland",
    ci: "Côte d'Ivoire",
    ck: "Cook Islands",
    cl: "Chile",
    cm: "Cameroon",
    cn: "China",
    co: "Colombia",
    cr: "Costa Rica",
    cu: "Cuba",
    cv: "Cabo Verde",
    cw: "Curaçao",
    cx: "Christmas Island",
    cy: "Cyprus",
    cz: "Czechia",
    de: "Germany",
    dj: "Djibouti",
    dk: "Denmark",
    dm: "Dominica",
    do: "Dominican Republic",
    dz: "Algeria",
    ec: "Ecuador",
    ee: "Estonia",
    eg: "Egypt",
    eh: "Western Sahara",
    er: "Eritrea",
    es: "Spain",
    et: "Ethiopia",
    fi: "Finland",
    fj: "Fiji",
    fk: "Falkland Islands (Malvinas)",
    fm: "Micronesia, Federated States of",
    fo: "Faroe Islands",
    fr: "France",
    ga: "Gabon",
    gb: "United Kingdom",
    gd: "Grenada",
    ge: "Georgia",
    gf: "French Guiana",
    gg: "Guernsey",
    gh: "Ghana",
    gi: "Gibraltar",
    gl: "Greenland",
    gm: "Gambia",
    gn: "Guinea",
    gp: "Guadeloupe",
    gq: "Equatorial Guinea",
    gr: "Greece",
    gs: "South Georgia and the South Sandwich Islands",
    gt: "Guatemala",
    gu: "Guam",
    gw: "Guinea-Bissau",
    gy: "Guyana",
    hk: "Hong Kong",
    hm: "Heard Island and McDonald Islands",
    hn: "Honduras",
    hr: "Croatia",
    ht: "Haiti",
    hu: "Hungary",
    id: "Indonesia",
    ie: "Ireland",
    il: "Israel",
    im: "Isle of Man",
    in: "India",
    io: "British Indian Ocean Territory",
    iq: "Iraq",
    ir: "Iran, Islamic Republic of",
    is: "Iceland",
    it: "Italy",
    je: "Jersey",
    jm: "Jamaica",
    jo: "Jordan",
    jp: "Japan",
    ke: "Kenya",
    kg: "Kyrgyzstan",
    kh: "Cambodia",
    ki: "Kiribati",
    km: "Comoros",
    kn: "Saint Kitts and Nevis",
    kp: "Korea, Democratic People's Republic of",
    kr: "Korea, Republic of",
    kw: "Kuwait",
    ky: "Cayman Islands",
    kz: "Kazakhstan",
    la: "Lao People's Democratic Republic",
    lb: "Lebanon",
    lc: "Saint Lucia",
    li: "Liechtenstein",
    lk: "Sri Lanka",
    lr: "Liberia",
    ls: "Lesotho",
    lt: "Lithuania",
    lu: "Luxembourg",
    lv: "Latvia",
    ly: "Libya",
    ma: "Morocco",
    mc: "Monaco",
    md: "Moldova, Republic of",
    me: "Montenegro",
    mf: "Saint Martin, (French part)",
    mg: "Madagascar",
    mh: "Marshall Islands",
    mk: "North Macedonia",
    ml: "Mali",
    mm: "Myanmar",
    mn: "Mongolia",
    mo: "Macao",
    mp: "Northern Mariana Islands",
    mq: "Martinique",
    mr: "Mauritania",
    ms: "Montserrat",
    mt: "Malta",
    mu: "Mauritius",
    mv: "Maldives",
    mw: "Malawi",
    mx: "Mexico",
    my: "Malaysia",
    mz: "Mozambique",
    na: "Namibia",
    nc: "New Caledonia",
    ne: "Niger",
    nf: "Norfolk Island",
    ng: "Nigeria",
    ni: "Nicaragua",
    nl: "Netherlands",
    no: "Norway",
    np: "Nepal",
    nr: "Nauru",
    nu: "Niue",
    nz: "New Zealand",
    om: "Oman",
    pa: "Panama",
    pe: "Peru",
    pf: "French Polynesia",
    pg: "Papua New Guinea",
    ph: "Philippines",
    pk: "Pakistan",
    pl: "Poland",
    pm: "Saint Pierre and Miquelon",
    pn: "Pitcairn",
    pr: "Puerto Rico",
    ps: "Palestine, State of",
    pt: "Portugal",
    pw: "Palau",
    py: "Paraguay",
    qa: "Qatar",
    re: "Réunion",
    ro: "Romania",
    rs: "Serbia",
    ru: "Russian Federation",
    rw: "Rwanda",
    sa: "Saudi Arabia",
    sb: "Solomon Islands",
    sc: "Seychelles",
    sd: "Sudan",
    se: "Sweden",
    sg: "Singapore",
    sh: "Saint Helena, Ascension and Tristan da Cunha",
    si: "Slovenia",
    sj: "Svalbard and Jan Mayen",
    sk: "Slovakia",
    sl: "Sierra Leone",
    sm: "San Marino",
    sn: "Senegal",
    so: "Somalia",
    sr: "Suriname",
    ss: "South Sudan",
    st: "Sao Tome and Principe",
    sv: "El Salvador",
    sx: "Sint Maarten, (Dutch part)",
    sy: "Syrian Arab Republic",
    sz: "Eswatini",
    tc: "Turks and Caicos Islands",
    td: "Chad",
    tf: "French Southern Territories",
    tg: "Togo",
    th: "Thailand",
    tj: "Tajikistan",
    tk: "Tokelau",
    tl: "Timor-Leste",
    tm: "Turkmenistan",
    tn: "Tunisia",
    to: "Tonga",
    tr: "Turkey",
    tt: "Trinidad and Tobago",
    tv: "Tuvalu",
    tw: "Taiwan",
    tz: "Tanzania, United Republic of",
    ua: "Ukraine",
    ug: "Uganda",
    um: "United States Minor Outlying Islands",
    us: "United States",
    uy: "Uruguay",
    uz: "Uzbekistan",
    va: "Holy See",
    vc: "Saint Vincent and the Grenadines",
    ve: "Venezuela, Bolivarian Republic of",
    vg: "Virgin Islands, British",
    vi: "Virgin Islands, U.S.",
    vn: "Viet Nam",
    vu: "Vanuatu",
    wf: "Wallis and Futuna",
    ws: "Samoa",
    xx: "Unknown",
    xk: "Kosovo",
    ye: "Yemen",
    yt: "Mayotte",
    za: "South Africa",
    zm: "Zambia",
    zw: "Zimbabwe",
  },
  $vuetify: {
    badge: "Badge",
    open: "Open",
    close: "Close",
    dismiss: "Dismiss",
    confirmEdit: {
      ok: "OK",
      cancel: "Cancel",
    },
    dataIterator: {
      noResultsText: "No matching records found",
      loadingText: "Loading items...",
    },
    dataTable: {
      itemsPerPageText: "Rows per page:",
      ariaLabel: {
        sortDescending: "Sorted descending.",
        sortAscending: "Sorted ascending.",
        sortNone: "Not sorted.",
        activateNone: "Activate to remove sorting.",
        activateDescending: "Activate to sort descending.",
        activateAscending: "Activate to sort ascending.",
      },
      sortBy: "Sort by",
    },
    dataFooter: {
      itemsPerPageText: "Items per page:",
      itemsPerPageAll: "All",
      nextPage: "Next page",
      prevPage: "Previous page",
      firstPage: "First page",
      lastPage: "Last page",
      pageText: "{0}-{1} of {2}",
    },
    dateRangeInput: {
      divider: "to",
    },
    datePicker: {
      itemsSelected: "{0} selected",
      range: {
        title: "Select dates",
        header: "Enter dates",
      },
      title: "Select date",
      header: "Enter date",
      input: {
        placeholder: "Enter date",
      },
    },
    noDataText: "No data available",
    carousel: {
      prev: "Previous visual",
      next: "Next visual",
      ariaLabel: {
        delimiter: "Carousel slide {0} of {1}",
      },
    },
    calendar: {
      moreEvents: "{0} more",
      today: "Today",
    },
    input: {
      clear: "Clear {0}",
      prependAction: "{0} prepended action",
      appendAction: "{0} appended action",
      otp: "Please enter OTP character {0}",
    },
    fileInput: {
      counter: "{0} files",
      counterSize: "{0} files ({1} in total)",
    },
    timePicker: {
      am: "AM",
      pm: "PM",
      title: "Select Time",
    },
    pagination: {
      ariaLabel: {
        root: "Pagination Navigation",
        next: "Next page",
        previous: "Previous page",
        page: "Go to page {0}",
        currentPage: "Page {0}, Current page",
        first: "First page",
        last: "Last page",
      },
    },
    stepper: {
      next: "Next",
      prev: "Previous",
    },
    rating: {
      ariaLabel: {
        item: "Rating {0} of {1}",
      },
    },
    loading: "Loading...",
    infiniteScroll: {
      loadMore: "Load more",
      empty: "No more",
    },
  },
};
