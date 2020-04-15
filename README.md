## Windows Code Signing

## Why should we code sign?
- identify the publisher
- confirm that the code has not been altered or tampered
- when Window encounters `unsigned code`, a security warning pops which create doubt and confusion for users. When `signed code` is encountered, a pop-up notification shows the `verified identity` of the publisher and the user decides whether or not to trust the code.

## How to code sign on Windows?
Each platform has slightly different ways of handling digital signatures. Windows utilize `Authenticode`. Authenticode allows software vendors to embedded-sign a number of Windows file formats, including:
*	Portable executable (PE): `.exe, .dll, .sys, and .ocx`
*	Cabinet (`.cab`) 
	A file that stores multiple compressed files in a file library. The cabinet format is an efficient way to package files because compression is performed across file boundaries, significantly improving the compression ratio.
*	Windows Installer (`.msi and .msp`) 
	A file format for software packages or patches that are installed by the Windows Installer.
* Powershell (`ps1 & ps2`)
* Windows store applications (`appx`)

Pretty much any type that support [SIP (subject interface package)](https://bit.ly/3c7d6pA). 

> What file types is supported by `Set-AuthenticodeSignature cmdlet`
	
## How Does code signing work? 
- There's two type of digital signatures: Embedded Signatures & Detached Signatures

## Embedded Signatures
> Embedded signing protects an individual file by inserting a signature into a nonexecution portion of the file. The advantage of using an embedded signature is that the required tool set is simpler and the signature is in the file itself.

> By default, embedded signatures are supported for only the limited set of file formats. All other formats are supported through signed catalog files. However, the Authenticode infrastructure has a provider model to support embedded signing and verification for other file formats. An Authenticode provider is called a subject interface package (SIP) and must be installed separately by the application that requires the new file format.

## Detached Signatures
> With signed catalog (`.cat`) files, the signing process requires generating a file hash value from the contents of a target file. This hash value is then included in a catalog file. The catalog file is then signed with an embedded signature. Catalog files are a type of detached signature.

> The advantage of using signed catalog files is that they can support all types of file formats, especially file formats that cannot accommodate an embedded signature. In addition, catalog files are more efficient if a software publisher must digitally sign many files because the entire set of files requires only a single signing operation

> A file can be both embedded and catalog signed

## How to add digital signature
> The `Set-AuthenticodeSignature` cmdlet adds an Authenticode signature to any file that supports Subject Interface Package (SIP).

- create a cert
`Set-AuthenticodeSignature -Certificate $cert -FilePath .\Desktop\file.to.sign.exe`

- sign exe
`$cert2=Get-PfxCertificate .\SignupCqureAG.pfx`
`Set-AuthenticodeSignature -Certificate $cert -FilePath .\Desktop\file2.exe -TimestampServer http://tsa.startssl.come/timestamp`

## Refs
- [SIP (Subject Interface Packages)](https://vcsjones.dev/2017/08/10/subject-interface-packages)
- [Best Practice](https://docs.microsoft.com/en-us/previous-versions/windows/hardware/design/dn653556(v=vs.85))


```bash
# cert store
certmgr.msc

# Create certificate:
$cert = New-SelfSignedCertificate -DnsName some@local.com -Type CodeSigning -CertStoreLocation Cert:\CurrentUser\My

# set the password for it:
$CertPassword = ConvertTo-SecureString -String "password123" -Force –AsPlainText

# export
Export-PfxCertificate -Cert "cert:\CurrentUser\My\$($cert.Thumbprint)" -FilePath "c:\tmp\codesign\selfsigncert.pfx" -Password $CertPassword

$env:Path = "C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool;"+$env:Path
signtool.exe sign /f "c:\tmp\codesign\selfsigncert.pfx" /p "password123" /v "C:\tmp\codesign\HelloWorld.dll"
```