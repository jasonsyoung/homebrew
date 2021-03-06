require "formula"

class Stunnel < Formula
  homepage "https://www.stunnel.org/"
  url "ftp://ftp.nluug.nl/pub/networking/stunnel/beta/stunnel-5.07b2.tar.gz"
  mirror "https://www.stunnel.org/downloads/beta/stunnel-5.07b2.tar.gz"
  sha256 "e9826952f3a56e0f631c0f8e8372297067de9ca8b05a596007015887c38d226d"

  # Any building-against openssl that has disabled sslv2 for now must use the betas.
  # This is upstream's recommendation. We should be able to go stable again from 5.07.
  # https://www.stunnel.org/pipermail/stunnel-users/2014-October/004806.html

  bottle do
    revision 1
    sha1 "4573f9e98df403f868cc9d11fbd4bdd43f5ce1f6" => :yosemite
    sha1 "e542f22d94991e0203d4a5df263216f22bbd2ce1" => :mavericks
    sha1 "736e9069642c42560a2122f145a2de84e5a3cc9d" => :mountain_lion
  end

  depends_on "openssl"

  def install
    # This causes a bogus .pem to be created in lieu of interactive cert generation.
    stunnel_cnf = Pathname.new("tools/stunnel.cnf")
    stunnel_cnf.unlink
    stunnel_cnf.write <<-EOS.undent
      # OpenSSL configuration file to create a server certificate
      # by Michal Trojnara 1998-2013

      [ req ]
      # the default key length is secure and quite fast - do not change it
      default_bits                    = 2048
      # comment out the next line to protect the private key with a passphrase
      encrypt_key                     = no
      distinguished_name              = req_dn
      x509_extensions                 = cert_type
      prompt                          = no

      [ req_dn ]
      countryName                     = PL
      stateOrProvinceName             = Mazovia Province
      localityName                    = Warsaw
      organizationName                = Stunnel Developers
      organizationalUnitName          = Provisional CA
      0.commonName                    = localhost

      # To create a certificate for more than one name uncomment:
      # 1.commonName                  = DNS alias of your server
      # 2.commonName                  = DNS alias of your server
      # ...
      # See http://home.netscape.com/eng/security/ssl_2.0_certificate.html
      # to see how Netscape understands commonName.

      [ cert_type ]
      nsCertType                      = server
    EOS

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--mandir=#{man}",
                          "--disable-libwrap",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install", "cert"
  end

  def caveats
    <<-EOS.undent
      A bogus SSL server certificate has been installed to:
        #{etc}/stunnel/stunnel.pem

      This certificate will be used by default unless a config file says otherwise!

      In your stunnel configuration, specify a SSL certificate with
      the "cert =" option for each service.
    EOS
  end
end
