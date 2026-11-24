final: prev: {
  yabai = prev.yabai.overrideAttrs (_: {
    version = "7.3.5";

    src = prev.fetchFromGitHub {
      owner = "Christian-SC26";
      repo = "yabai";
      rev = "v7.3.5";
      hash = "sha256-jQsnH/vtn8V2v9pJSMDXcqHy367REzIJtuc5tizsNRI=";
    };
  });
}
