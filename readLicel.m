function data = readLicel(filename)
% This function loads a licel *.txt file and save the content in the 
% struct "data".
% The .txt file can be generated from the binary file using the Licel 
% software Advance Viewer.
% Author: Emanuele Avocone

    % Open the file in read mode
    fid = fopen(filename,'r');
    if fid ~=-1
        % The first row is the name of the file
        r1 = fgetl(fid);

        % The second row
        formatSpec = '%s %s %s %s %s %f %f %f %f %f';
        r2 = textscan(fgetl(fid), formatSpec);
        loc = r2{1}{1};
        starttime = datetime(cat(2,r2{2}{1},' ',r2{3}{1}),'InputFormat','dd/MM/uuuu HH:mm:ss');
        stoptime = datetime(cat(2,r2{4}{1},' ',r2{5}{1}),'InputFormat','dd/MM/uuuu HH:mm:ss');
        height = r2{6};
        long = r2{7};
        lat = r2{8};
        za = r2{9};
        aa = r2{10};

        % The third row
        r3 = textscan(fgetl(fid), '%u %u %u %u %u %u %u %u %u');
        nsl1 = r3{1}; % Laser 1 Number of shots
        prfl1 = r3{2}; % Pulse repetition frequency for laser 1
        nsl2 = r3{3}; % Laser 2 Number of shots
        prfl2 = r3{4}; % Pulse repetition frequency for laser 2
        nsl3 = r3{6}; % Laser 3 Number of shots
        prfl3 = r3{7}; % Pulse repetition frequency for laser 3
        Np = r3{5}; % Number of profiles or channels

        data.Station.FileName               = r1;
        data.Station.Location               = loc;
        data.Station.HeightASL              = height;
        data.Station.StartTime              = starttime;
        data.Station.StopTime               = stoptime;
        data.Station.Latitude               = lat;
        data.Station.Longitude              = long;
        data.Station.ZenithAngle            = za;
        data.Station.AzimuthAngle           = aa;
        data.Station.Channels               = Np;
        data.Station.Laser1Shots            = nsl1;    			
        data.Station.Laser1Freq             = prfl1;
        data.Station.Laser2Shots            = nsl2;    			
        data.Station.Laser2Freq             = prfl2;
        data.Station.Laser3Shots            = nsl3;    			
        data.Station.Laser3Freq             = prfl3;

        % The following Np rows
        for i = 1:Np
            % maybe it is better to use '%q' so the quotation marks "" are ignored 
            tt = textscan(fgetl(fid), '%s');
            try
                data.Channel(i).Info        = cat(2,tt{1}{17}(2:end),' ',tt{1}{18}(1:end-1));
            catch
                try
                    data.Channel(i).Info    = tt{1}{17}(2:end-1);
                catch
                    data.Channel(i).Info    = '';
                end
            end
            data.Channel(i).Descriptor      = tt{1}{16};
            data.Channel(i).Type            = str2double(tt{1}{2});
            data.Channel(i).Active          = tt{1}{1};
            data.Channel(i).Laser           = tt{1}{3};
            data.Channel(i).Bins            = str2double(tt{1}{4});
            data.Channel(i).laserpol        = tt{1}{5};
            data.Channel(i).HV              = str2double(tt{1}{6});
            data.Channel(i).BinWidth        = str2double(tt{1}{7});
            data.Channel(i).LaserWL         = str2double(tt{1}{8}(1:5));
            data.Channel(i).Polarization    = tt{1}{8}(7);
            data.Channel(i).BinShift        = tt{1}{11};
            data.Channel(i).BinShift2       = tt{1}{12};
            data.Channel(i).ADCbits         = str2double(tt{1}{13});
            data.Channel(i).Shots           = str2double(tt{1}{14});
            data.Channel(i).Discriminator   = str2double(tt{1}{15});
            clear tt        
        end

        fgetl(fid); % We ignore this row

        % Now there are the Np profiles
        formatSpec = '%f';
        if Np>1
            for i=1:Np-1
                formatSpec = cat(2,formatSpec,' %f');
            end
        end                        
        sizeA = [Np Inf];
        A = fscanf(fid,formatSpec, sizeA);
        A = A';
        for i = 1:Np
            data.Channel(i).Signal = A(1:data.Channel(i).Bins,i);
            data.Channel(i).Range = data.Channel(i).BinWidth.*(1:length(data.Channel(i).Signal))';
        end
        clear A
        
        % Close the file
        fclose(fid);
    end
end