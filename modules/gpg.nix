{
  programs.gpg = {
    enable = true;
    publicKeys = [ {
      # myself
      trust = 5;
      text = ''
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        mDMEYlQbxxYJKwYBBAHaRw8BAQdAL3fAjgSzVFnz2uqLgjDeS6RbxjVQX8Yig7Rw
        2ayUyQO0FUFuaWxsYyA8dm9pZEBhbmlsLmxjPoiOBBMWCgA2FiEEYUEeT/4Qznsu
        FM12C+ioj0eyFFwFAmmm6vECGwMECwkIBwQVCgkIBRYCAwEAAh4BAheAAAoJEAvo
        qI9HshRci18A/R7jrg9xYA7Vfg2veqtBqTvJPEpT3Cf47pR0Sg3xTIWjAP4tOlb/
        98vznukMSrqiIULy3JBkD7q0x6Q7nlfVDRMKDbQSQW5pbGxjIDxpQGFuaWwubGM+
        iI4EExYKADYWIQRhQR5P/hDOey4UzXYL6KiPR7IUXAUCaabp9wIbAwQLCQgHBBUK
        CQgFFgIDAQACHgECF4AACgkQC+ioj0eyFFzUXAEA34vfTh61u1XAsyaxq7hVaYnv
        CfzmarLr5tz62wfByt8A/01Zoe2N0MNNvX+BuK4nfobmsP9TawizOs1sGGNH00QH
        uDgEYlQbxxIKKwYBBAGXVQEFAQEHQEnL7lC9znrT/5JAj+L8H+Fbp+cXfLA2egXe
        GCZQPsghAwEIB4h4BBgWCgAgFiEEYUEeT/4QznsuFM12C+ioj0eyFFwFAmJUG8cC
        GwwACgkQC+ioj0eyFFydTwD9HR3MQjvcLpwmpGcW85YVSJHWdZa2NyqV+wp3i5o9
        OdQA/2QY/hB8BJRkadJwQDg4Op2WgOR+puTjM3XWoCVp6qUG
        =beet
        -----END PGP PUBLIC KEY BLOCK-----
      '';
    } ];
  };
}
