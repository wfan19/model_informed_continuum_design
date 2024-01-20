function [mat_rxns, mat_rl, mat_rgb] = f_moment_image(f_reaction, rhos, l_0s, ax, options)

    arguments
        f_reaction                      % f(rho, l_0): Reaction force generated by an arm segment as a function of the segment geometry
        rhos                            % List of segment radii to compute reactions at
        l_0s                            % List of segment neutral lengths to compute reactions at
        ax                              % Axis to plot on
        options.N_widths = 20           % If only two values are provided for rhos, then the number of rhos to interpolate
        options.N_neutral_lengths = 20  % If only two values are provided for l_0s, then the number of neutral lengths to interpolate
    end

    if length(rhos) == 2
        rhos = linspace(rhos(1), rhos(2), options.N_widths);
        N_w = options.N_widths;
    else
        N_w = length(rhos);
    end

    if length(l_0s) == 2
        l_0s = linspace(l_0s(1), l_0s(2), options.N_neutral_lengths);
        N_l_0 = options.N_neutral_lengths;
    else
        N_l_0 = length(l_0s);
    end

    cell_wl = cell(N_w, N_l_0);
    cell_arm_segments = cell(N_w, N_l_0);
    cell_rxns = cell(N_w, N_l_0);
    cell_colors = cell(N_w, N_l_0);
    for i = 1 : N_w
        rho_i = rhos(i);
        for j = 1 : N_l_0
            l_0_j = l_0s(j);
            % Calculate the internal reaction moment that the muscles would create
            % at that curvature.
            [segment_ij, rxn] = f_reaction(rho_i, l_0_j);
        
            cell_arm_segments{i, j} = segment_ij;
            cell_wl{i, j} = [rho_i; l_0_j];
            cell_rxns{i, j} = rxn;
            cell_colors{i, j} = [i/N_w * 0.8; j/N_l_0 * 0.75 + 0.25; 1];
        end
    end
    
    mat_rl = [cell_wl{:}];
    mat_rxns = [cell_rxns{:}];
    mat_hsv = [cell_colors{:}];
    mat_rgb = hsv2rgb(mat_hsv');

    if isa(ax, "matlab.graphics.axis.Axes")
        hold on

        u_rxns_all_spaced = nan(3, 1);
        for i = 1 : size(cell_rxns, 1)
            mat_rxns_i = [cell_rxns{i, :}, nan(3, 1)];
            u_rxns_all_spaced = horzcat(u_rxns_all_spaced, mat_rxns_i);
        end

        v_rxns_all_spaced = nan(3, 1);
        for i = 1 : size(cell_rxns, 2)
            mat_rxns_i = [cell_rxns{:, i}, nan(3, 1)];
            v_rxns_all_spaced = horzcat(v_rxns_all_spaced, mat_rxns_i);
        end

        plot(u_rxns_all_spaced(1, :), u_rxns_all_spaced(3, :), 'k')
        plot(v_rxns_all_spaced(1, :), v_rxns_all_spaced(3, :), 'k')
        
        scatter(mat_rxns(1, :), mat_rxns(3, :), [], mat_rgb, "filled");
        
        grid on
        xlabel("Reaction stretch (N)")
        ylabel("Reaction moment (Nm)")
    end
end
