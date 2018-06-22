function Invoke-TervisCAProvision {
    Invoke-ApplicationProvision -ApplicationName "CertificateAuthority"

    #Errors when run from etsn, currently must be run via powershell prompt opened via RDP
    Read-Host "All of the following commands have to be run via a powershell prompt opened over RDP and cannot be run via invoke command"
    Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CryptoProviderName "ECDSA_P256#Microsoft Software Key Storage Provider" -KeyLength 256 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 99 -Force
    $ThumbPrint = gci Cert:\LocalMachine\My\ | Where-Object {$_.subject} | Select-Object -ExpandProperty ThumbPrint
    Install-AdcsEnrollmentPolicyWebService -AuthenticationType Kerberos -SSLCertThumbprint $ThumbPrint -Force

    Install-AdcsEnrollmentWebService -ApplicationPoolIdentity -AuthenticationType Kerberos -SSLCertThumbprint $ThumbPrint -force
    Install-AdcsWebEnrollment -force
    Install-AdcsOnlineResponder -force
    #NDES wants a separate servcie account when run on the same system as the root CA, not needed now so will work on this later
    #Install-AdcsNetworkDeviceEnrollmentService -ApplicationPoolIdentity -Force

    Install-Module -Name ADCSTemplate
    #https://github.com/GoateePFE/ADCSTemplate
}