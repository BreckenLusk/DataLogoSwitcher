#import <Foundation/Foundation.h>
#import <firmware.h>

#define SettingsPath @"/var/mobile/Library/Preferences/tw.hiraku.datalogoswitcher.plist"

//Before iOS 12.2
typedef NS_ENUM(NSInteger, connectionType) {
    ConnectionNone          = 0,
    Connection1x            = 1,
    ConnectionGprs          = 2,
    ConnectionEdge          = 3,
    ConnectionUmts          = 4,
    ConnectionHsdpa         = 5,
    Connection4GOverride    = 6,
    ConnectionLte           = 7,
    ConnectionBluetooth     = 8,
    ConnectionWifi          = 9,
    ConnectionOther         = 10
};

//After iOS 12.2
typedef NS_ENUM(NSInteger, newConnectionType) {
    NewConnectionNone       = 0,
    NewConnection1x         = 1,
    NewConnectionGprs       = 2,
    NewConnectionEdge       = 3,
    NewConnectionUmts       = 4,
    NewConnectionHsdpa      = 5,
    NewConnection4GOverride = 6,
    NewConnectionLte        = 7,
    NewConnectionLteA       = 8,
    NewConnectionLtePlus    = 9,
    NewConnection5GE        = 10,
    NewConnectionBluetooth  = 11,
    NewConnectionWifi       = 12,
    NewConnectionOther      = 13
};


%group GiOS12_2
%hook SBTelephonySubscriptionContext
- (int)modemDataConnectionType
{
    int connectionType = %orig;

    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:SettingsPath];
    if (connectionType == NewConnectionUmts || connectionType == NewConnectionHsdpa)
    {
        switch([defaults[@"3G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return NewConnection4GOverride;
            case 2:
                return NewConnectionLte;
            case 3:
                return NewConnectionLteA;
            case 4:
                return NewConnectionLtePlus;
            case 5:
                return NewConnection5GE;
            default:
                break;
        }
    }

    if (connectionType == NewConnection4GOverride || 
        connectionType == NewConnectionLte || 
        connectionType == NewConnectionLteA || 
        connectionType == NewConnectionLtePlus || 
        connectionType == NewConnection5GE)
    {
        switch([defaults[@"4G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return NewConnection4GOverride;
            case 2:
                return NewConnectionLte;
            case 3:
                return NewConnectionLteA;
            case 4:
                return NewConnectionLtePlus;
            case 5:
                return NewConnection5GE;
            default:
                break;
        }
    }

    return connectionType;
}
%end
%end


%group GiOS12_1
%hook SBTelephonySubscriptionContext
- (int)modemDataConnectionType
{
    int connectionType = %orig;

    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:SettingsPath];
    if (connectionType == ConnectionUmts || connectionType == ConnectionHsdpa)
    {
        switch([defaults[@"3G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return Connection4GOverride;
            case 2:
                return ConnectionLte;
            default:
                break;
        }
    }

    if (connectionType == Connection4GOverride || connectionType == ConnectionLte)
    {
        switch([defaults[@"4G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return Connection4GOverride;
            case 2:
                return ConnectionLte;
            default:
                break;
        }
    }

    return connectionType;
}
%end
%end

%group GiOS12
%hook SBMutableTelephonyCarrierBundleInfo
- (BOOL)LTEConnectionShows4G
{
    return NO;
}
%end
%end

%hook SBTelephonyManager
- (int)dataConnectionType 
{
    int connectionType = %orig;
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:SettingsPath];
    
    if (connectionType == ConnectionUmts || connectionType == ConnectionHsdpa)
    {
        switch([defaults[@"3G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return Connection4GOverride;
            case 2:
                return ConnectionLte;
            default:
                break;
        }
    }

    if (connectionType == Connection4GOverride || connectionType == ConnectionLte)
    {
        switch([defaults[@"4G"] intValue])
        {
            case 0:
                return connectionType;
            case 1:
                return Connection4GOverride;
            case 2:
                return ConnectionLte;
            default:
                break;
        }
    }

    return connectionType;
}
%end

%ctor 
{
    %init;
    if (kCFCoreFoundationVersionNumber_iOS_12_0 >= kCFCoreFoundationVersionNumber_iOS_12_0)
    {
        %init(GiOS12);

        if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_12_2) 
        {
            %init(GiOS12_1);
        }
        else
        {
            %init(GiOS12_2);
        }
    }
}