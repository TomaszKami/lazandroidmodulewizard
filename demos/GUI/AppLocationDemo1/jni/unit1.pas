{Hint: save all files to location: C:\adt32\eclipse\workspace\AppLocationDemo1\jni }
unit unit1;
  
{$mode delphi}
  
interface
  
uses
  Classes, SysUtils, And_jni, And_jni_Bridge, Laz_And_Controls, 
  Laz_And_Controls_Events, AndroidWidget, location;
  
type

  { TAndroidModule1 }

  TAndroidModule1 = class(jForm)
      jButton1: jButton;
      jButton2: jButton;
      jCheckBox1: jCheckBox;
      jLocation1: jLocation;
      jTextView1: jTextView;
      jWebView1: jWebView;
      procedure AndroidModule1RequestPermissionResult(Sender: TObject;
        requestCode: integer; manifestPermission: string;
        grantResult: TManifestPermissionResult);
      procedure DataModuleJNIPrompt(Sender: TObject);
      procedure jButton1Click(Sender: TObject);
      procedure jButton2Click(Sender: TObject);
      procedure jCheckBox1Click(Sender: TObject);
      procedure jLocation1GpsStatusChanged(Sender: TObject;
        countSatellites: integer; gpsStatusEvent: TGpsStatusEvent);
      procedure jLocation1LocationChanged(Sender: TObject; latitude: double;
        longitude: double; altitude: double; address: string);
      procedure jLocation1LocationProviderDisabled(Sender: TObject;
        provider: string);
      procedure jLocation1LocationProviderEnabled(Sender: TObject;
        provider: string);
      procedure jLocation1LocationStatusChanged(Sender: TObject;
        status: integer; provider: string; msgStatus: string);
    private
      {private declarations}
    public
      {public declarations}
  end;
  
var
  AndroidModule1: TAndroidModule1;

implementation
  
{$R *.lfm}

{ TAndroidModule1 }

procedure TAndroidModule1.DataModuleJNIPrompt(Sender: TObject);
begin

  if not Self.isConnected() then
  begin //try wifi
    if Self.SetWifiEnabled(True) then
      jCheckBox1.Checked:= True
    else
      ShowMessage('Please,  try enable some connection...');
  end
  else
  begin
    if Self.isConnectedWifi() then jCheckBox1.Checked:= True
  end;

    //https://developer.android.com/guide/topics/security/permissions#normal-dangerous
    //https://www.captechconsulting.com/blogs/runtime-permissions-best-practices-and-how-to-gracefully-handle-permission-removal
  if IsRuntimePermissionNeed() then   // that is, target API >= 23
  begin
     ShowMessage('RequestRuntimePermission....');
     Self.RequestRuntimePermission('android.permission.ACCESS_FINE_LOCATION', 1003); //from AndroodManifest.xml
  end;

end;

procedure TAndroidModule1.AndroidModule1RequestPermissionResult(
  Sender: TObject; requestCode: integer; manifestPermission: string;
  grantResult: TManifestPermissionResult);
begin
    case requestCode of
     1003:begin   //android.permission.ACCESS_FINE_LOCATION
               if grantResult = PERMISSION_GRANTED  then
               begin
                   ShowMessage(manifestPermission + ' :: Success! Permission grant!!! ' )
               end
               else  //PERMISSION_DENIED
                 ShowMessage(manifestPermission + '   :: Sorry... permission not grant... ' )
           end;
  end;
end;

procedure TAndroidModule1.jCheckBox1Click(Sender: TObject);
begin
   if jCheckBox1.Checked then
   begin
     if not jLocation1.IsWifiEnabled() then
       jLocation1.SetWifiEnabled(True)
     else
       ShowMessage('Wifi is Enabled!');
   end
   else
   begin
      jLocation1.SetWifiEnabled(False);
      ShowMessage('Wifi was Disabled!');
   end;
end;

procedure TAndroidModule1.jLocation1GpsStatusChanged(Sender: TObject;
  countSatellites: integer; gpsStatusEvent: TGpsStatusEvent);
var
  i: integer;
begin

  case gpsStatusEvent of

     gpsStarted: ShowMessage('gpsStarted');

     gpsStopped: ShowMessage('gpsStopped');

     gpsFirstFix: ShowMessage('gpsFirstFix = ' +FloatToStr( jLocation1.GetTimeToFirstFix() ) );

     gpsSatelliteStatus:
     begin
       ShowMessage('Satellites count = '+IntToStr(countSatellites));
       for i:= 0 to countSatellites-1 do
       begin
         ShowMessage('Satellite ['+IntToStr(i)+'] Info: ' +jLocation1.GetSatelliteInfo(i));
       end;
     end;

  end;

end;

procedure TAndroidModule1.jLocation1LocationChanged(Sender: TObject;
  latitude: double; longitude: double; altitude: double; address: string);
var
  urlLocation: string;
begin

  //jLocation1.SetGoogleMapsApiKey('mykey');    // << ----------  IMPORTANT !!!!

  if jLocation1.GoogleMapsApiKey = '' then
  begin
    ShowMessage('Found address='+ address);
    ShowMessage('Sorry .... Google Static Maps API needs an apikey...');
    jLocation1.StopTracker();
    Exit;
  end;

  urlLocation:= jLocation1.GetGoogleMapsUrl(latitude, longitude);
  jWebView1.Navigate(urlLocation);

  jLocation1.StopTracker();
  jLocation1.ShowLocationSourceSettings()

end;

procedure TAndroidModule1.jButton1Click(Sender: TObject);
begin
  if IsRuntimePermissionGranted('android.permission.ACCESS_FINE_LOCATION')  then
  begin
      if not jLocation1.IsGPSProvider then
      begin
         ShowMessage('Sorry, GPS is Off. Please, active it and try again.');
         jLocation1.ShowLocationSourceSettings();
      end
      else
      begin
         ShowMessage('GPS is On! Starting Tracker...');
         //jLocation1.MapType:= mtHybrid;  // default/mtRoadmap, mtSatellite, mtTerrain, mtHybrid
         jLocation1.StartTracker();  //handled by "OnLocationChanged"
      end;
  end
  else  ShowMessage('Sorry.. Runtime Permission NOT Granted ...');
end;

{
40.737102,-73.990318
40.749825,-73.987963
40.752946,-73.987384
40.755823,-73.986397
}

procedure TAndroidModule1.jButton2Click(Sender: TObject); //no GPS is need! only wifi...
var
  //lat: TDynArrayOfDouble;
  //lon: TDynArrayOfDouble;
  //ll: TDynArrayOfDouble;
  urlLocation: string;
begin

  //jLocation1.SetGoogleMapsApiKey('mykey');    // << ----------  IMPORTANT !!!!

  if jLocation1.GoogleMapsApiKey = '' then
  begin
    ShowMessage('warning: Google Static Maps API needs an apikey. Look at the https://developers.google.com/maps/documentation/static-maps');
    Exit;
  end;

  //jLocation1.MapType:= mtHybrid;     // default/mtRoadmap, mtSatellite, mtTerrain, mtHybrid

  (* TEST 1       //'UFMT,  Barra do Garças, Mato Grosso, Brasil'
  ll:= jLocation1.GetLatitudeLongitude('Super Center Mendonça, AV. Minstro João Alberto, centro, Barra do Garças, Mato Grosso, Brasil');
  urlLocation:= jLocation1.GetGoogleMapsUrl(ll[0], ll[1]);
  jWebView1.Navigate(urlLocation);
  SetLength(ll,0);
  *)

  (*TEST 2
  urlLocation:= jLocation1.GetGoogleMapsUrl('Super Center Mendonça, AV. Minstro João Alberto, centro, Barra do Garças, Mato Grosso, Brasil');
  jWebView1.Navigate(urlLocation);
  *)

  (*TEST 3
  SetLength(lat,4);
  SetLength(lon,4);
  lat[0]:=  40.737102;
  lat[1]:=  40.749825;
  lat[2]:=  40.752946;
  lat[3]:=  40.755823;

  lon[0]:= -73.990318;
  lon[1]:= -73.987963;
  lon[2]:= -73.987384;
  lon[3]:= -73.986397;

  urlLocation:= jLocation1.GetGoogleMapsUrl(lat, lon);
  jWebView1.Navigate(urlLocation);
  SetLength(lat,0);
  SetLength(lon,0);
  *)

  //Test 4
  urlLocation:= jLocation1.GetGoogleMapsUrl([GeoPoint2D(40.737102,-73.990318),
                                             GeoPoint2D(40.749825,-73.987963),
                                             GeoPoint2D(40.752946,-73.987384),
                                             GeoPoint2D(40.755823,-73.986397)
                                            ]);
  jWebView1.Navigate(urlLocation);

end;

procedure TAndroidModule1.jLocation1LocationProviderDisabled(Sender: TObject; //GPS OFF
  provider: string);
begin
   ShowMessage('provider= '+provider +' : Disabled!');
end;

procedure TAndroidModule1.jLocation1LocationProviderEnabled(Sender: TObject; //GPS ON
  provider: string);
begin
  ShowMessage('New provider= '+provider +' : Enabled!');
end;

procedure TAndroidModule1.jLocation1LocationStatusChanged(Sender: TObject;
  status: integer; provider: string; msgStatus: string);
begin
  ShowMessage('provider= '+provider+' ::: msgStatus= '+ msgStatus);
end;

end.
