% bootlogistic takes in the bootstrap samples, and returns the slope
% parameter from the fit.
function [slope bias] = bootlogistic(bstrp_trials);

global data;
TEMPO_Defs;		
Path_Defs;
ProtocolDefs;	%needed for all protocol specific functions - contains keywords - BJP 1/4/01

direction = data.dots_params(DOTS_DIREC, :, PATCH1);
unique_direction = munique(direction(bstrp_trials)');
Pref_direction = data.one_time_params(PREFERRED_DIRECTION);
coherence = data.dots_params(DOTS_COHER, :, PATCH1);
unique_coherence = munique(coherence');
signed_coherence = [-munique(coherence'); munique(coherence')]';
[sorted_coherence I] = sort(signed_coherence);

for j=1:length(unique_direction)
    for k=1:length(unique_coherence)
        ind = k + (j-1)*sum(unique_coherence~=2);
        ok_values{ind} = bstrp_trials(find( (coherence(bstrp_trials) == unique_coherence(k)) ...
            & (direction(bstrp_trials) == unique_direction(j)) ));
        pct_pd(ind) = sum(data.misc_params(OUTCOME, ok_values{ind}) == CORRECT)/length(ok_values{ind});
        n_obs(ind) = length(ok_values{ind});
        if (unique_direction(j) ~= Pref_direction)
            pct_pd(ind) = 1-pct_pd(ind);
        end
    end
end

[logistic_alpha logistic_beta] = logistic_fit([sorted_coherence' pct_pd(I)' n_obs(I)']);
slope = logistic_alpha;
bias = logistic_beta;

return
