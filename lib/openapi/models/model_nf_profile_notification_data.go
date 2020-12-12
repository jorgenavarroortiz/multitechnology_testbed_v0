/*
 * NRF NFManagement Service
 *
 * NRF NFManagement Service
 *
 * API version: 1.0.1
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package models
import (
	"time"
)

type NfProfileNotificationData struct {
	NfInstanceId string `json:"nfInstanceId" yaml:"nfInstanceId" bson:"nfInstanceId" mapstructure:"NfInstanceId"`
	NfType NfType `json:"nfType" yaml:"nfType" bson:"nfType" mapstructure:"NfType"`
	NfStatus NfStatus `json:"nfStatus" yaml:"nfStatus" bson:"nfStatus" mapstructure:"NfStatus"`
	HeartBeatTimer int32 `json:"heartBeatTimer,omitempty" yaml:"heartBeatTimer" bson:"heartBeatTimer" mapstructure:"HeartBeatTimer"`
	PlmnList []PlmnId `json:"plmnList,omitempty" yaml:"plmnList" bson:"plmnList" mapstructure:"PlmnList"`
	SNssais []Snssai `json:"sNssais,omitempty" yaml:"sNssais" bson:"sNssais" mapstructure:"SNssais"`
	PerPlmnSnssaiList []PlmnSnssai `json:"perPlmnSnssaiList,omitempty" yaml:"perPlmnSnssaiList" bson:"perPlmnSnssaiList" mapstructure:"PerPlmnSnssaiList"`
	NsiList []string `json:"nsiList,omitempty" yaml:"nsiList" bson:"nsiList" mapstructure:"NsiList"`
	Fqdn string `json:"fqdn,omitempty" yaml:"fqdn" bson:"fqdn" mapstructure:"Fqdn"`
	InterPlmnFqdn string `json:"interPlmnFqdn,omitempty" yaml:"interPlmnFqdn" bson:"interPlmnFqdn" mapstructure:"InterPlmnFqdn"`
	Ipv4Addresses []string `json:"ipv4Addresses,omitempty" yaml:"ipv4Addresses" bson:"ipv4Addresses" mapstructure:"Ipv4Addresses"`
	Ipv6Addresses []string `json:"ipv6Addresses,omitempty" yaml:"ipv6Addresses" bson:"ipv6Addresses" mapstructure:"Ipv6Addresses"`
	AllowedPlmns []PlmnId `json:"allowedPlmns,omitempty" yaml:"allowedPlmns" bson:"allowedPlmns" mapstructure:"AllowedPlmns"`
	AllowedNfTypes []NfType `json:"allowedNfTypes,omitempty" yaml:"allowedNfTypes" bson:"allowedNfTypes" mapstructure:"AllowedNfTypes"`
	AllowedNfDomains []string `json:"allowedNfDomains,omitempty" yaml:"allowedNfDomains" bson:"allowedNfDomains" mapstructure:"AllowedNfDomains"`
	AllowedNssais []Snssai `json:"allowedNssais,omitempty" yaml:"allowedNssais" bson:"allowedNssais" mapstructure:"AllowedNssais"`
	Priority int32 `json:"priority,omitempty" yaml:"priority" bson:"priority" mapstructure:"Priority"`
	Capacity int32 `json:"capacity,omitempty" yaml:"capacity" bson:"capacity" mapstructure:"Capacity"`
	Load int32 `json:"load,omitempty" yaml:"load" bson:"load" mapstructure:"Load"`
	Locality string `json:"locality,omitempty" yaml:"locality" bson:"locality" mapstructure:"Locality"`
	UdrInfo *UdrInfo `json:"udrInfo,omitempty" yaml:"udrInfo" bson:"udrInfo" mapstructure:"UdrInfo"`
	UdmInfo *UdmInfo `json:"udmInfo,omitempty" yaml:"udmInfo" bson:"udmInfo" mapstructure:"UdmInfo"`
	AusfInfo *AusfInfo `json:"ausfInfo,omitempty" yaml:"ausfInfo" bson:"ausfInfo" mapstructure:"AusfInfo"`
	AmfInfo *AmfInfo `json:"amfInfo,omitempty" yaml:"amfInfo" bson:"amfInfo" mapstructure:"AmfInfo"`
	SmfInfo *SmfInfo `json:"smfInfo,omitempty" yaml:"smfInfo" bson:"smfInfo" mapstructure:"SmfInfo"`
	UpfInfo *UpfInfo `json:"upfInfo,omitempty" yaml:"upfInfo" bson:"upfInfo" mapstructure:"UpfInfo"`
	PcfInfo *PcfInfo `json:"pcfInfo,omitempty" yaml:"pcfInfo" bson:"pcfInfo" mapstructure:"PcfInfo"`
	BsfInfo *BsfInfo `json:"bsfInfo,omitempty" yaml:"bsfInfo" bson:"bsfInfo" mapstructure:"BsfInfo"`
	ChfInfo *ChfInfo `json:"chfInfo,omitempty" yaml:"chfInfo" bson:"chfInfo" mapstructure:"ChfInfo"`
	NrfInfo *NrfInfo `json:"nrfInfo,omitempty" yaml:"nrfInfo" bson:"nrfInfo" mapstructure:"NrfInfo"`
	CustomInfo map[string]interface{} `json:"customInfo,omitempty" yaml:"customInfo" bson:"customInfo" mapstructure:"CustomInfo"`
	RecoveryTime *time.Time `json:"recoveryTime,omitempty" yaml:"recoveryTime" bson:"recoveryTime" mapstructure:"RecoveryTime"`
	NfServicePersistence bool `json:"nfServicePersistence,omitempty" yaml:"nfServicePersistence" bson:"nfServicePersistence" mapstructure:"NfServicePersistence"`
	NfServices []NfService `json:"nfServices,omitempty" yaml:"nfServices" bson:"nfServices" mapstructure:"NfServices"`
	NfProfileChangesSupportInd bool `json:"nfProfileChangesSupportInd,omitempty" yaml:"nfProfileChangesSupportInd" bson:"nfProfileChangesSupportInd" mapstructure:"NfProfileChangesSupportInd"`
	NfProfileChangesInd bool `json:"nfProfileChangesInd,omitempty" yaml:"nfProfileChangesInd" bson:"nfProfileChangesInd" mapstructure:"NfProfileChangesInd"`
	DefaultNotificationSubscriptions []DefaultNotificationSubscription `json:"defaultNotificationSubscriptions,omitempty" yaml:"defaultNotificationSubscriptions" bson:"defaultNotificationSubscriptions" mapstructure:"DefaultNotificationSubscriptions"`
}
