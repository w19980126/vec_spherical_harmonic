classdef NSphHarmonic < handle
    % SphHarmonic - Vector Spherical Harmonics
    %
    % 
    
    %properties (GetAccess='private', SetAccess='private')
    properties (SetAccess='private')
        % Parent object
        parent;
        
        %    Nx,Ny,Nz  The N vector over a cube of space
        Nx;
        Ny;
        Nz;
        %    and over the surface of a sphere
        Nx_sph;
        Ny_sph;
        Nz_sph;
        %    Nav       The angular velocity of N as generated by curl()
        Nav;
        %    Mangx,
        %    Mangy,
        %    Mangz     The phi and theta components of M only.
        %    Mang      Absolute value of above
        Nangx;
        Nangy;
        Nangz;
        Nang;
        
    end
    
    methods
        %
        % SETUP functions
        %
        
        function hObj = NSphHarmonic(parent)
            hObj.parent = parent;
            
            % Calculate the vector spherical harmonic N=(curl M)/k
            [hObj.Nx, hObj.Ny, hObj.Nz, hObj.Nav] = ...
                curl(hObj.parent.x, hObj.parent.y, hObj.parent.z,...
                hObj.parent.M.Mx, hObj.parent.M.My, hObj.parent.M.Mz);

            % Supposed to be dividing by k here, but since we are using
            % spherical harmonics instead of the proper function, we just set
            % the wavelength to 1.
            hObj.Nx = hObj.Nx/(2*pi);
            hObj.Ny = hObj.Ny/(2*pi);
            hObj.Nz = hObj.Nz/(2*pi);

            % Get vector components over the unit sphere
            hObj.Nx_sph = interp3(hObj.parent.x, hObj.parent.y, hObj.parent.z, hObj.Nx,...
                hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);
            hObj.Ny_sph = interp3(hObj.parent.x, hObj.parent.y, hObj.parent.z, hObj.Ny,...
                hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);
            hObj.Nz_sph = interp3(hObj.parent.x, hObj.parent.y, hObj.parent.z, hObj.Nz,...
                hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);
            
            % Need to take the cross product of MN with the unit
            % radial vector.
            hObj.Nangx = hObj.parent.y.*hObj.Nz - hObj.parent.z.*hObj.Ny;
            hObj.Nangy = -(hObj.parent.x.*hObj.Nz - hObj.parent.z.*hObj.Nx);
            hObj.Nangz = hObj.parent.x.*hObj.Ny - hObj.parent.y.*hObj.Nx;

            % Get vector components over the unit sphere
            hObj.Nangx = interp3(hObj.parent.x, hObj.parent.y, hObj.parent.z,...
                hObj.Nangx, hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);
            hObj.Nangy = interp3(hObj.parent.x, hObj.parent.y, hObj.parent.z,...
                hObj.Nangy, hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);
            hObj.Nangz = interp3(hObj.parent.x,hObj.parent.y, hObj.parent.z,...
                hObj.Nangz, hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph);

            hObj.Nang = sqrt(hObj.Nangx.^2 + hObj.Nangy.^2 + hObj.Nangz.^2);
        
        end
        
        %% 
        %
        % PLOTTING functions
        %
        
        function plot_ang(hObj)
            figure;

            surf(hObj.parent.x_sph.*real(hObj.Nang), hObj.parent.y_sph.*real(hObj.Nang), ...
                hObj.parent.z_sph.*real(hObj.Nang), real(hObj.Nang),...
                'EdgeColor', 'flat', 'FaceColor','interp');
            switch hObj.parent.parity 
                case Parity.Even
                    title_str = sprintf('$$|\\mathrm{(r/|r|)\\times N^e_{%d,%d}}|$$', hObj.parent.l, hObj.parent.m);
                case Parity.Odd
                    title_str = sprintf('$$|\\mathrm{(r/|r|)\\times N^o_{%d,%d}}|$$', hObj.parent.l, hObj.parent.m);
                otherwise
                    title_str = sprintf('$$|\\mathrm{(r/|r|)\\times N_{%d,%d}}|$$', hObj.parent.l, hObj.parent.m);
            end
            title(title_str,'Interpreter','latex');
            xlabel('x');
            ylabel('y');
            zlabel('z');
            colormap jet;
        end
        
        function plot_ang_vec(hObj)
            figure;

            quiver3(hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph, ...
                hObj.Nangx, hObj.Nangy, hObj.Nangz, hObj.parent.arrow_scale,...
                'Color', 'black');
            switch hObj.parent.parity 
                case Parity.Even
                    title_str = sprintf('$$\\mathrm{(r/|r|)\\times N^e_{%d,%d}}$$', hObj.parent.l, hObj.parent.m);
                case Parity.Odd
                    title_str = sprintf('$$\\mathrm{(r/|r|)\\times N^o_{%d,%d}}$$', hObj.parent.l, hObj.parent.m);
                otherwise
                    title_str = sprintf('$$\\mathrm{(r/|r|)\\times N_{%d,%d}}$$', hObj.parent.l, hObj.parent.m);
            end
            title(title_str,'Interpreter','latex');
            xlabel('x');
            ylabel('y');
            zlabel('z');
            hold on;
            surf(hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph, real(hObj.parent.Yln_sph),...
                    'EdgeColor', 'interp', 'FaceColor','none');
            hold off;
            colormap jet;
            pbaspect([1 1 1]);
        end
        
        function plot_ang_abs_vec(hObj)
            figure;

            % The vector field is the real parts of N, so we want the
            % absolute value of the real parts of the vectors.
            abs_vec = sqrt(real(hObj.Nangx).^2 + real(hObj.Nangy).^2 + real(hObj.Nangz).^2);
            surf(hObj.parent.x_sph.*abs_vec, hObj.parent.y_sph.*abs_vec, hObj.parent.z_sph.*abs_vec,...
                abs_vec, 'EdgeColor', 'flat', 'FaceColor','interp');
            
            switch hObj.parent.parity 
                case Parity.Even
                    title_str = sprintf('$$\\mathrm{|(r/|r|)\\times N^e_{%d,%d}|}$$', hObj.parent.l, hObj.parent.m);
                case Parity.Odd
                    title_str = sprintf('$$\\mathrm{|(r/|r|)\\times N^o_{%d,%d}|}$$', hObj.parent.l, hObj.parent.m);
                otherwise
                    title_str = sprintf('$$\\mathrm{|(r/|r|)\\times N_{%d,%d}|}$$', hObj.parent.l, hObj.parent.m);
            end
            title(title_str,'Interpreter','latex');
            xlabel('x');
            ylabel('y');
            zlabel('z');
            hold on;
            surf(hObj.parent.x_sph, hObj.parent.y_sph, hObj.parent.z_sph, real(hObj.parent.Yln_sph),...
                    'EdgeColor', 'interp', 'FaceColor','none');
            hold off;
            colormap jet;
            pbaspect([1 1 1]);
        end
        %% 
        %
        % SUNDRY functions
        %

        function set_pbaspect(hObj)
            % Sets the axes of the spherical harmonic plot so that each axis
            % has the same scale.  ie, none of the axes are cramped.
            switch hObj.parent.l
                case 0
                    pba = [1 1 1];
                case 1
                    switch hObj.parent.m
                        case -1
                            pba = [2 1 1];
                        case 0
                            pba = [1 1 2];
                        case 1
                            pba = [2 1 1];
                    end
                case 2
                    switch hObj.parent.m
                        case -2
                            pba = [3 3 1];
                        case -1
                            pba = [3 1 3];
                        case 0
                            pba = [1 1 4];
                        case 1
                            pba = [3 1 3];
                        case 2
                            pba = [3 3 1];
                    end
                case 3
                    switch hObj.parent.m
                        case -3
                            pba = [4 4 1];
                        case -2
                            pba = [3 3 2];
                        case -1
                            pba = [3 1 4];
                        case 0
                            pba = [1 1 6];
                        case 1
                            pba = [3 1 4];
                        case 2
                            pba = [3 3 2];
                        case 3
                            pba = [4 4 1];
                    end
                otherwise
                    pba = [1 1 1];
            end
            if hObj.parent.l<=3
                pbaspect(pba);
            end
        end
    end
end

