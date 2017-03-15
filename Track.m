classdef Track
    % Implementation of a Track 
    %   A track is a sequence of observations and/or filtered states which
    %   corresponds to an object
    
    properties
        filter;
        sequence_times_observations; % the time instants at which observations are associated
        sequence_observations; % the set of observations associated to this track
        sequence_times; % all the time instants during which this track is active
        sequence_predicted_observations; % the observations predicted by the internal state
        sequence_updated_state;% filtered output values
        state;% to determine is early stage or inactive or active
        sequence_times_notobserved; % to determine whether the radar was pointed somewhere else
    end
    
    methods
        function o = Track(filter_type, filter_parameters, time, initial_observation)
            if strcmp(filter_type,'kalmanfilter')
                o.filter = KalmanFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'alphabetafilter')
                o.filter = AlphaBetaFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'extendedkalmanfilter')
                initial_observation = filter_parameters.hinv(initial_observation); % conversion into the actual state co-ordinates
                o.filter = ExtendedKalmanFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'unscentedkalmanfilter')
                initial_observation = filter_parameters.hinv(initial_observation); % conversion into the actual state co-ordinates
                o.filter = UnscentedKalmanFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'staticmultimodal')
                o.filter = StaticMultiModalFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'interactingmultimodal')
                o.filter = InteractingMultiModalFilter(filter_parameters, time, initial_observation);
            elseif strcmp(filter_type, 'multistepkalmanfilter')
                o.filter = MultiStepUpdateKalmanFilter(filter_parameters, time, initial_observation);
            end
            o.sequence_times_observations = [];
            o.sequence_observations = {};
            o.sequence_times = [];
            o.sequence_predicted_observations = {};
            o.state = 1; %%%% 0 for inactive 1 for early stage 2 for active
            o.sequence_times_notobserved = [];
        end
        
        function o = predict(o)
            o.filter = o.filter.predict();
        end
        
        % Records the observation generated by the underlying state of this
        % track (should be called at every point where the track is active)
        function o = record_predicted_observation(o, time)
            o.sequence_times = [o.sequence_times, time];
            o.sequence_predicted_observations{end + 1} = o.get_predicted_observation();
        end
        
        % Records the first observation when the track is born
        function o = record_first_observation(o, time)
            o.sequence_times = [o.sequence_times, time];
            o.sequence_predicted_observations{end + 1} = o.get_observation(); % since there is no first prediction
            o.sequence_updated_state{end + 1} = o.get_observation();
        end
        
        % Records an actual observation which has been associated to this
        % track
        function o = record_associated_observation(o, time, observation)
            o.sequence_times_observations = [o.sequence_times_observations, time];
            o.sequence_observations{end + 1} = observation;
        end
        
        function o = update(o, time, observation)
            o.filter = o.filter.update(time, observation);
        end
        
        function o = update_with_noobservation(o, time, observation)
            o.filter = o.filter.update_with_noobservation(time);
        end
        
        function o = update_with_multiple_observations(o, time, observations, observation_probability, probability_no_assoc_observation)
            o.filter = o.filter.update_with_multiple_observations(time, observations, observation_probability, probability_no_assoc_observation);
        end
        
        function o = split_track(o)
            o.sequence_times_observations = [];
            o.sequence_updated_state = [];%%% added raghava
            o.sequence_observations = {};
            o.sequence_times = [];
            o.sequence_predicted_observations = {};
        end
        
        function observation = get_observation(o)
            observation = o.filter.get_observation();
        end
        
        function predicted_observation = get_predicted_observation(o)
            predicted_observation = o.filter.get_predicted_observation();
        end
        
        function innovation_covariance = get_innovation_covariance(o)
            innovation_covariance = o.filter.get_innovation_covariance();
        end
        
        function o = record_updated_state(o, time)
           
            o.sequence_updated_state{end + 1} = o.get_observation();
        end
        
        %%%% added raghava
         function o = record_notobserved_times(o, time)
            o.sequence_times_notobserved = [o.sequence_times_notobserved, time];         
         end
    end
end

