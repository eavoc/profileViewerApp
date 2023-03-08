function data = readLicelBin(filename)
% This function loads a licel binary file and save the content in the 
% struct "data"
% Author: Emanuele Avocone
    
    %% Open File
    fid = fopen(filename,'r');

    %% Read MetaData
    data.Station.Name           = fscanf(fid,'%s',1);
    data.Station.Location       = fscanf(fid,'%s',1);
    data.Station.StartTime      = datetime(cat(2,fscanf(fid,'%s',1),' ',fscanf(fid,'%s',1)),'InputFormat','dd/MM/uuuu HH:mm:ss');
    data.Station.StopTime       = datetime(cat(2,fscanf(fid,'%s',1),' ',fscanf(fid,'%s',1)),'InputFormat','dd/MM/uuuu HH:mm:ss');
    data.Station.HeightASL      = fscanf(fid,'%f',1);			
    data.Station.Latitude       = fscanf(fid,'%s',1);			
    data.Station.Longitude      = fscanf(fid,'%s',1);			
    data.Station.ZenithAngle    = fscanf(fid,'%f',1);			
    data.Station.AzimuthAngle   = fscanf(fid,'%f',1);			
    data.Station.Laser1Shots    = fscanf(fid,'%f',1);			
    data.Station.Laser1Freq     = fscanf(fid,'%f',1);			
    data.Station.Laser2Shots    = fscanf(fid,'%f',1);			
    data.Station.Laser2Freq     = fscanf(fid,'%f',1);			
    data.Station.Channels       = fscanf(fid,'%f',1);			
    data.Station.Laser3Shots    = fscanf(fid,'%f',1);			
    data.Station.Laser3Freq     = fscanf(fid,'%f',1);
    fscanf(fid,'%f',1); % reserved
    fscanf(fid,'%f',1); % reserved
    
    for i = 1:data.Station.Channels
        data.Channel(i).Active          = fscanf(fid,'%f',1);
        data.Channel(i).Type            = fscanf(fid,'%f',1);
        data.Channel(i).Laser           = fscanf(fid,'%f',1);
        data.Channel(i).Bins            = fscanf(fid,'%f',1);
        data.Channel(i).LPolarization   = fscanf(fid,'%f',1);
        data.Channel(i).HV              = fscanf(fid,'%f',1);
        data.Channel(i).BinWidth        = fscanf(fid,'%f',1);
        data.Channel(i).LWavelength     = fscanf(fid,'%f',1);
        data.Channel(i).Polarization    = fscanf(fid,'%s',1);
        fscanf(fid,'%f',1);
        fscanf(fid,'%f',1);
        data.Channel(i).BinShift        = fscanf(fid,'%f',1);
        data.Channel(i).BinShift2       = fscanf(fid,'%f',1);
        data.Channel(i).ADC             = fscanf(fid,'%f',1);
        data.Channel(i).Shots           = fscanf(fid,'%f',1);
        data.Channel(i).Discriminator   = fscanf(fid,'%f',1);
        data.Channel(i).Descriptor      = fscanf(fid,'%s',1);
        info                            = fscanf(fid,'%s',1);
        data.Channel(i).Info            = info(2:end-1);
    end
    
    %% Go to the profiles
    fgetl(fid);
    
    %% Read the lidar profiles
    % For the conversion from Raw Data to Physical value see the
    % Programming Manual
    
    c = 299792458;
    
    for i=1:data.Station.Channels
        
        s=1; % conversion factor
        
        % Analog
        if data.Channel(i).Type==0
            s = 1000*data.Channel(i).Discriminator/(2^data.Channel(i).ADC- ...
                1)/data.Channel(i).Shots; % conversion factor -> mV
        % Photon Counting
        elseif data.Channel(i).Type==1
            s = (c/(2*1e06))/data.Channel(i).BinWidth/data.Channel(i).Shots; % conversion factor -> MHz
        % Analog squared    
        elseif data.Channel(i).Type==2
            s = 1000*data.Channel(i).Discriminator/(2^data.Channel(i).ADC-1);
            N = data.Channel(i).Shots;
            s = s/sqrt(N*(N-1));
            s = s/sqrt(N); 
        % Photon Counting squared
        elseif data.Channel(i).Type==3
            s = (c/(2*1e06))/data.Channel(i).BinWidth;
            N = data.Channel(i).Shots;
            s = s/sqrt(N*(N-1));
            s = s/sqrt(N);
        end
        
        fseek(fid,2,'cof');	% Here you can add a check (CRLF)
        temp = fread(fid, data.Channel(i).Bins, 'long');
        data.Channel(i).Signal = temp*s;
        data.Channel(i).Range = data.Channel(i).BinWidth.*(1:length(data.Channel(i).Signal))';
    end
    fclose(fid);
end